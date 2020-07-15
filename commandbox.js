'use strict';

const { exec } = require('child_process');
const path = require('path');
const { dialog, app } = require('electron');

let path_to_module = __dirname;

// Starts a CommandBox Instance
module.exports.start = function (resource_path, commandbox_home) {
    boxExecute(resource_path, 'server start', commandbox_home);
}

// Stops CommandBox Instance
module.exports.stop = function (resource_path, commandbox_home) {
    boxExecute(resource_path, 'server stop', commandbox_home);
}

// Custom CommandBox Commands
module.exports.execute = function (resource_path, command, commandbox_home) {
    boxExecute(resource_path, command. commandbox_home);
}

function boxExecute(resource_path, command, commandbox_home) {
    require('find-java-home')(function(err, home){
        if(err || typeof(home) != 'string') {
            dialog.showMessageBox({
                title: 'Unable to Find Java',
                message: 'Unable to find java on your computer.',
                detail: 'If you have java installed make sure you set JAVA_HOME, or install Java 11 from: https://adoptopenjdk.net'
            });
            console.log(err);
            console.log(home);
            return;
        }

        

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
    });
}

function execute(command, callback) {
    exec(command, (error, stdout, stderr) => { 
        if( error ) {
            if ( stdout ) {
                dialog.showMessageBox({
                    title: 'Failed to Start CommandBox',
                    message: 'Failed to Start CommandBox',
                    detail: stdout.toString()
               });  
            }
            callback(error, true);

        }
        if( stderr ) {
          callback(stderr, true);
          dialog.showMessageBox({
                title: 'Failed to Start CommandBox',
                message: 'Failed to Start CommandBox',
                detail: stderr.toString()
           });  
        }
        if( stdout ) callback(stdout, false)
    })
}