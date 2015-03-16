/* This file is part of mac2imgur.
*
* mac2imgur is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* mac2imgur is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with mac2imgur.  If not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var accountItem: NSMenuItem!
    @IBOutlet weak var deleteAfterUploadOption: NSMenuItem!
    @IBOutlet weak var disableDetectionOption: NSMenuItem!
    @IBOutlet weak var requireConfirmationOption: NSMenuItem!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var imgurClient = ImgurClient()
    var monitor: ScreenshotMonitor!
    var authController: ImgurAuthWindowController!
    var statusItem: NSStatusItem!
    var activeIcon: NSImage!
    var inactiveIcon: NSImage!
    
    // Delegate methods
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        // Create status bar icons
        inactiveIcon = NSImage(named: "StatusInactive")!
        inactiveIcon.setTemplate(true)
        activeIcon = NSImage(named: "StatusActive")!
        activeIcon.setTemplate(true)
        
        // Set account menu item to relevant title
        updateAccountItemTitle()
        
        // Bind menu items to user defaults controller
        disableDetectionOption.bind("value", toObject: defaults, withKeyPath: kDisableScreenshotDetection, options: nil)
        deleteAfterUploadOption.bind("value", toObject: defaults, withKeyPath: kDeleteScreeenshotAfterUpload, options: nil)
        requireConfirmationOption.bind("value", toObject: defaults, withKeyPath: kRequiresUploadConfirmation, options: nil)
        
        // Add menu to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        statusItem.menu = menu
        statusItem.toolTip = "mac2imgur"
        updateStatusIcon(false)
        
        // Start monitoring for screenshots
        monitor = ScreenshotMonitor(callback: screenshotDetected)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
        monitor.query.stopQuery()
    }
    
    func screenshotDetected(imagePath: String) {
        // Check that screenshot detection has not been disabled
        if !defaults.boolForKey(kDisableScreenshotDetection) {
            if defaults.boolForKey(kRequiresUploadConfirmation) {
                let alert = NSAlert()
                alert.messageText = "Do you want to upload this screenshot?"
                alert.informativeText = "\"\(imagePath.lastPathComponent.stringByDeletingPathExtension)\" will be uploaded to imgur, where it is publicly accessible."
                alert.addButtonWithTitle("Upload")
                alert.addButtonWithTitle("Cancel")
                if alert.runModal() == NSAlertSecondButtonReturn {
                    return
                }
            }
            updateStatusIcon(true)
            let upload = ImgurUpload(imagePath: imagePath, isScreenshot: true, callback: uploadAttemptCompleted)
            imgurClient.addToQueue(upload)
        }
    }
    
    func uploadAttemptCompleted(upload: ImgurUpload) {
        updateStatusIcon(false)
        let type = upload.isScreenshot ? "Screenshot" : "Image"
        if upload.successful {
            displayNotification("\(type) uploaded successfully!", informativeText: upload.link!)
            
            if upload.isScreenshot && defaults.boolForKey(kDeleteScreeenshotAfterUpload) {
                println("Deleting screenshot @ \(upload.imagePath)")
                deleteFile(upload.imagePath)
            }
        } else {
            displayNotification("\(type) upload failed...", informativeText: "")
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        if let url = NSURL(string: notification.informativeText!) {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    // Selector methods
    
    @IBAction func selectImages(sender: NSMenuItem) {
        var panel = NSOpenPanel()
        panel.title = "Select Images"
        panel.prompt = "Upload"
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = ["jpg", "jpeg", "gif", "png", "apng", "tiff", "bmp", "pdf", "xcf"]
        if panel.runModal() == NSOKButton {
            for imageURL in panel.URLs {
                if let imagePath = (imageURL as! NSURL).path {
                    let upload = ImgurUpload(imagePath: imagePath, isScreenshot: false, callback: uploadAttemptCompleted)
                    imgurClient.addToQueue(upload)
                    updateStatusIcon(true)
                }
            }
        }
    }
    
    @IBAction func accountAction(sender: NSMenuItem) {
        if imgurClient.isAuthenticated {
            imgurClient.deleteCredentials()
            updateAccountItemTitle()
        } else {
            authController = ImgurAuthWindowController(windowNibName: "ImgurAuthWindow")
            authController.client = imgurClient
            authController.callback = {
                self.displayNotification("Signed in as \(self.imgurClient.username!)", informativeText: "")
                self.updateAccountItemTitle()
                self.authController.close()
            }
            NSApplication.sharedApplication().activateIgnoringOtherApps(true)
            authController.showWindow(self)
        }
    }
    
    @IBAction func about(sender: NSMenuItem) {
        NSApplication.sharedApplication().orderFrontStandardAboutPanel(sender)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    // Utility methods
    
    func copyToClipboard(string: String) {
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().setString(string, forType: NSStringPboardType)
    }
    
    func deleteFile(pathToFile: String) {
        var error: NSError?
        NSFileManager.defaultManager().removeItemAtPath(pathToFile, error: &error)
        if error != nil {
            NSLog("An error occurred while attempting to delete a file: %@", error!)
        }
    }
    
    func displayNotification(title: String, informativeText: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = informativeText
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    func updateStatusIcon(isActive: Bool) {
        statusItem.image = isActive ? activeIcon : inactiveIcon
    }
    
    func updateAccountItemTitle() {
        accountItem.title = imgurClient.isAuthenticated ? "Sign out (\(imgurClient.username!))" : "Sign in"
    }
}