#mac2imgur [![Build Status](http://ci.rauix.net/buildStatus/icon?job=mac2imgur)](http://ci.rauix.net/job/mac2imgur/)#


###Installation Instructions###

[Download](https://github.com/rauix/mac2imgur/releases) a release, then simply drop it into your 'Applications' folder.

**READ THIS IF YOU ARE USING OS X 10.8 OR LATER:** You will most likely have a feature called Gatekeeper enabled, if so, to open the application you will have to right-click it and then click 'Open'. (If that fails, you can [try additional steps listed here](http://support.apple.com/kb/ht5290)).

After opening it, you'll notice a small (hopefully unobtrusive) system tray icon:

![alt text](http://i.imgur.com/7bnd5pz.png "mac2imgur system tray icon")
---

###Usage###

#####Press **CMD + SHIFT + 4** to take a selection of the screen.#####

#####Press **CMD + SHIFT + 4 + SPACE** to take screenshot a specific window, menu or dialog.#####

#####Press **CMD + SHIFT + 3** to take a full-screen screenshot.#####

After you've taken a screenshot, you'll receive a notification via the Mac OS X Notification Center, telling you whether the upload was successful or not.

If the upload was successful, then your screenshot has been uploaded and the link has been copied to your clipboard.

![alt text](http://i.imgur.com/D7PAsRP.png "mac2imgur upload notification")
---

###Options###

There are a few options that you can change, via the options dialog (accessible by clicking the system tray icon, then selecting 'Preferences' from the popup menu) - these include:

* What happens to the screenshot after it is uploaded (it can be moved, deleted, or simply left as it is)
* Whether the direct link or gallery link is used
* If the screenshot should be opened in the browser after upload
* The directory monitored for new screenshots
* Select which formats should mac2imgur upload
* Choose between Anonymous or Account uploads

![alt text](http://i.imgur.com/xfjCQYL.png "mac2imgur options menu")
---

###Account support###
Since v2.4, mac2imgur gives support for account-uploading, giving you the option for managing and deleting the images you no longer want online.

Enabling it is as simple as going to the options dialog (accessible by clicking the system tray icon, then selecting 'Preferences' from the popup menu), Accounts option and at the Account section, just follow the instructions.
![Account support](http://i.imgur.com/G3jHSnI.png "Account support")
---

### Building your own .app###
If you would like compiling your own version of mac2imgur, you may read the wiki page I wrote, in order to make things easier to you: https://github.com/dexafree/mac2imgur/wiki/Building-the-.app

Also, I uploaded all the .jar files, in order to avoid any maven-dependency problem.

---
###Issues & Pull Requests###

If something isn't working as expected, feel free to [submit an issue](https://github.com/rauix/mac2imgur/issues).

On the same note, pull requests to fix issues add features or simply to improve the codebase are greatly appreciated - [fork](https://github.com/rauix/mac2imgur/fork) away! ;D
