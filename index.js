const {
    app,
    BrowserWindow,
    screen
} = require('electron');
const box = require('./commandbox');
const path = require('path');
const crypto = require('crypto');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win;

// Make sure this port matches the server.json port
const commandbox_port = 8584;

//var cfml_path = path.join(app.getAppPath(), 'cfml');
var resource_path = path.join(app.getAppPath(), 'resources');

app.enableSandbox();

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', () => {
    if (!process.env.FIXINATOR_GUI_HOME) {
        process.env.FIXINATOR_GUI_HOME = app.getPath('userData');    
    }
    //generate GUI key if not user overridden
    if (!process.env.FIXINATOR_GUI_KEY) {
        process.env.FIXINATOR_GUI_KEY = crypto.randomBytes(64).toString('hex');    
    }
    app.userAgentFallback = "fixinator-gui;" + process.env.FIXINATOR_GUI_KEY;
    if (app.isPackaged) {
        resource_path = path.join(process.resourcesPath, 'resources');
    }

    //console.log(app.isPackaged);
    startCommandBox();
    createWindow();
})

// Quit when all windows are closed.
app.on('window-all-closed', () => {
    // On macOS it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== 'darwin') {
        app.quit()
    }
})

app.on('activate', () => {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (win === null) {
        createWindow()
    }
})

app.on('quit', () => {
    stopCommandBox()
})


function createWindow() {

    // Create the browser window.
   
    var { width, height } = screen.getPrimaryDisplay().workAreaSize;

    console.log(height + " height");

    if ( width/2 > 800 ) {
        width = width/2;
    } else {
        width = width-100;
    }
    if ( height/1.5 > 600 ) {
        height = height/1.5;
    } else {
        height = height - 100;
    }

    win = new BrowserWindow({
        width: width,
        height: height,
        webPreferences: {
            nodeIntegration: false,
            devTools: false,
            sandbox: true
        }
    })

    // and load the index.html of the app.
    win.loadURL(`file://${__dirname}/index.html?port=${commandbox_port}`, {
        userAgent: "fixinator-gui;" + process.env.FIXINATOR_GUI_KEY
    });

    // Open the DevTools.
    //win.webContents.openDevTools()

    // Emitted when the window is closed.
    win.on('closed', () => {
        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        win = null;
    });
    //quit the app if all windows are closed
    app.on('window-all-closed', () => {
        app.quit()
    });
}

function getCommandBoxHome() {
    return path.join(process.env.FIXINATOR_GUI_HOME, "commandbox");
}

function startCommandBox() {
    var commandbox_home = getCommandBoxHome();
    console.log(commandbox_home);
    box.start(resource_path, commandbox_home);
}

function stopCommandBox() {
    box.stop(resource_path, getCommandBoxHome());
}