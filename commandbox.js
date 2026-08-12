'use strict';

const { exec, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const { dialog, app, BrowserWindow } = require('electron');

let path_to_module = __dirname;
let server_started = false;
let server_stopping = false;
let java_home_path = null;

const IS_WINDOWS = process.platform === 'win32';
const IS_MAC = process.platform === 'darwin';
const JAVA_BINARY = IS_WINDOWS ? 'java.exe' : 'java';

// Starts a CommandBox Instance
module.exports.start = function (resource_path, commandbox_home) {
    boxExecute(resource_path, 'server start', commandbox_home);
}

// Stops CommandBox Instance
module.exports.stop = function (resource_path, commandbox_home) {
    if (java_home_path != null && !server_stopping) {
        server_stopping = true;
        boxExecute(resource_path, 'server stop', commandbox_home);
    }
}

// Custom CommandBox Commands
module.exports.execute = function (resource_path, command, commandbox_home) {
    boxExecute(resource_path, command, commandbox_home);
}

/**
 * Locates a Java home directory without external dependencies.
 * Search order:
 *   1. The JAVA_HOME environment variable
 *   2. Common install locations for the current platform
 *   3. The `java` executable on the PATH (symlinks resolved)
 *
 * Calls back with (err, home) to match the old find-java-home signature.
 */
function findJavaHome(callback) {
    try {
        // 1. JAVA_HOME environment variable
        if (process.env.JAVA_HOME && dirIsJavaHome(process.env.JAVA_HOME)) {
            return callback(null, process.env.JAVA_HOME);
        }

        // 2. Common install locations
        var home = findInCommonLocations();
        if (home) {
            return callback(null, home);
        }

        // 3. Fall back to whatever `java` is on the PATH
        home = findInPath();
        if (home) {
            return callback(null, home);
        }

        callback(new Error('Unable to locate a Java installation.'), null);
    } catch (err) {
        callback(err, null);
    }
}

// Returns true if the directory exists and contains bin/java(.exe)
function dirIsJavaHome(dir) {
    try {
        return fs.statSync(dir).isDirectory()
            && fs.existsSync(path.join(dir, 'bin', JAVA_BINARY));
    } catch (e) {
        return false;
    }
}

// Lists immediate subdirectories of a directory, or [] if it doesn't exist
function subdirs(dir) {
    try {
        return fs.readdirSync(dir).map(function (name) {
            return path.join(dir, name);
        }).filter(function (p) {
            try {
                return fs.statSync(p).isDirectory();
            } catch (e) {
                return false;
            }
        });
    } catch (e) {
        return [];
    }
}

// Scans well-known install roots for the current platform and returns the
// newest valid Java home found, or null.
function findInCommonLocations() {
    var candidates = [];

    if (IS_WINDOWS) {
        var programFiles = process.env['ProgramFiles'] || 'C:\\Program Files';
        var programFilesX86 = process.env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)';
        var roots = [
            path.join(programFiles, 'Microsoft'),         // Microsoft OpenJDK
            path.join(programFiles, 'Eclipse Adoptium'),  // Temurin
            path.join(programFiles, 'Eclipse Foundation'),// older AdoptOpenJDK
            path.join(programFiles, 'Java'),              // Oracle JDK/JRE
            path.join(programFiles, 'Amazon Corretto'),
            path.join(programFiles, 'Zulu'),
            path.join(programFilesX86, 'Java')
        ];
        roots.forEach(function (root) {
            candidates = candidates.concat(subdirs(root));
        });
    } else if (IS_MAC) {
        // The official macOS resolver, if present
        try {
            var out = execSync('/usr/libexec/java_home', { stdio: ['ignore', 'pipe', 'ignore'] })
                .toString().trim();
            if (out) {
                candidates.push(out);
            }
        } catch (e) {
            // no JDK registered with java_home; keep scanning
        }
        subdirs('/Library/Java/JavaVirtualMachines').forEach(function (jvmDir) {
            candidates.push(path.join(jvmDir, 'Contents', 'Home'));
        });
        // Homebrew installs
        candidates.push('/opt/homebrew/opt/openjdk');
        candidates.push('/usr/local/opt/openjdk');
    } else {
        // Linux and friends
        ['/usr/lib/jvm', '/usr/java', '/opt/java', '/opt/jdk'].forEach(function (root) {
            candidates = candidates.concat(subdirs(root));
        });
    }

    // Return the first valid Java home found (candidates are in preference order)
    var valid = candidates.filter(dirIsJavaHome);
    return valid.length ? valid[0] : null;
}

// Resolves the `java` executable on the PATH back to its home directory
function findInPath() {
    try {
        var cmd = IS_WINDOWS ? 'where java' : 'which java';
        var out = execSync(cmd, { stdio: ['ignore', 'pipe', 'ignore'] })
            .toString().split(/\r?\n/)[0].trim();
        if (!out) {
            return null;
        }
        var real = fs.realpathSync(out);   // resolve symlinks (e.g. /usr/bin/java -> jvm dir)
        var home = path.dirname(path.dirname(real)); // strip /bin/java
        return dirIsJavaHome(home) ? home : null;
    } catch (e) {
        return null;
    }
}

function boxExecute(resource_path, command, commandbox_home) {
    if (java_home_path == null) {
        findJavaHome(function (err, home) {
            if (err || typeof (home) != 'string') {
                dialog.showMessageBox({
                    title: 'Unable to Find Java',
                    message: 'Unable to find java on your computer.',
                    detail: 'If you have java installed make sure you set JAVA_HOME, or install Java 11 from: https://www.microsoft.com/openjdk'
                }).then(function () {
                    app.quit();
                });
                console.log(err);
                console.log(home);

                return;
            }

            java_home_path = home;
            boxExecuteWithJava(resource_path, command, commandbox_home, java_home_path);
        });
    } else {
        boxExecuteWithJava(resource_path, command, commandbox_home, java_home_path);
    }
}

function boxExecuteWithJava(resource_path, command, commandbox_home, java_home) {
    var home = java_home;
    if (!commandbox_home) {
        var properties_path = path.join(resource_path, 'commandbox', 'home');
        commandbox_home = properties_path;
    }

    var properites_data = `-commandbox_home="${commandbox_home}"`;

    var java_path = path.join(home, 'bin', 'java');
    var box_path = path.join(resource_path, 'box.jar');
    var cfml_path = path.join(resource_path, 'cfml');
    var cmd = `cd "${cfml_path}" && "${java_path}" -jar "${box_path}" ${properites_data} ${command}`;
    console.log(cmd);
    execute(cmd, (output, failed) => {
        console.log(output);
    })
}

function execute(command, callback) {
    exec(command, (error, stdout, stderr) => {
        if (error) {
            if (stdout) {
                dialog.showMessageBox({
                    title: 'Failed to Start CommandBox',
                    message: 'Failed to Start CommandBox',
                    detail: stdout.toString()
                });
            }
            callback(error, true);

        }
        if (stderr) {
            callback(stderr, true);
            dialog.showMessageBox({
                title: 'Failed to Start CommandBox',
                message: 'Failed to Start CommandBox',
                detail: stderr.toString()
            });
        }
        if (stdout) {
            if (command.indexOf('server start') != -1) {
                server_started = true;
            }
            callback(stdout, false);
        }
    })
}