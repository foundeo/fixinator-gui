# Fixinator GUI

> The native GUI version of Fixinator has been discontinued. In the near future we will be re-releasing this app as a GUI web application instead of a native exe. In the meantime please use the commandbox cli interface, or the [fixinator-runner](https://github.com/foundeo/fixinator-runner/) scheduled task.

Fixinator GUI is a Native applications for Windows or Mac OS to run [Fixinator](https://fixinator.app) scans.

![Fixinator GUI Demo](https://github.com/foundeo/fixinator-demos/blob/main/fixinator-gui-2021-06-11-01-sm.gif?raw=true)

## Installation

### Prerequisites 

If you do not have Java installed, or you're not sure if you have the latest version of java, start by downloading and installing the latest version of **Java 11** from [AdoptOpenJDK](https://adoptopenjdk.net/). 

### Windows Installation

Download the [latest Fixinator-Setup-x.y.z.exe](https://github.com/foundeo/fixinator-gui/releases/latest) from the Releases section.

Double click the setup exe. The exe is signed with a code signing certificate, however Windows Defender may prevent you from running the app because you have downloaded it from the internet. Click _More Info_ and verify that the publisher is _Foundeo Inc._ and then you can hit _Run Anyway_.

### Mac Installation

Download the [latest Fixinator-x.y.z.dmg](https://github.com/foundeo/fixinator-gui/releases/latest) from the Releases page.

Double click the dmg file, and then drag the Fixinator icon into the Applications folder.

Go to the Applications folder, and right click on Fixinator and select Open. 

### Standalone Web Application 

You can also run Fixinator GUI as a web application with CommandBox. Just download or clone this repo, and then run:

    cd resources/cfml/
    box server start 

This will open the application in a browser window instead of a native Windows or Mac app window.

## Uninstall

### Windows

Open the _Add Remove Programs_ from the Windows Control Panel, locate Fixinator and click Uninstall.

Application data is stored in `C:\Users\UserName\AppData\Local\Programs\Fixinator` and configuration data in `C:\Users\UserName\AppData\Roaming\Fixinator` by default.

### Mac

Delete the Fixinator.app from the Applications folder. Configuration data is stored in `~/Library/Application Support/Fixinator`
