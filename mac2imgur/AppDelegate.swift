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
import Fabric
import Crashlytics
import ImgurFx

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, NSWindowDelegate, NSMenuDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var accountItem: NSMenuItem!
    @IBOutlet weak var deleteAfterUploadOption: NSMenuItem!
    @IBOutlet weak var disableDetectionOption: NSMenuItem!
    @IBOutlet weak var requireConfirmationOption: NSMenuItem!
    @IBOutlet weak var resizeScreenshotsOption: NSMenuItem!
    @IBOutlet weak var launchAtLoginOption: NSMenuItem!
    
    let activeIcon = NSImage(named: "StatusActive")!
    let inactiveIcon = NSImage(named: "StatusInactive")!
    let defaults = NSUserDefaults.standardUserDefaults()
    let imgurClient = ImgurClient()
    var monitor: ScreenshotMonitor!
    var statusItem: NSStatusItem!
    
    // Delegate methods
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        defaults.registerDefaults(["NSApplicationCrashOnExceptions": true])
        
        // Crashlytics integration
        Fabric.with([Crashlytics()])

        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: "handleURLEvent:withReplyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        // Bind menu items to user defaults controller
        disableDetectionOption.bind("value", toObject: defaults, withKeyPath: kDisableScreenshotDetection, options: nil)
        deleteAfterUploadOption.bind("value", toObject: defaults, withKeyPath: kDeleteScreeenshotAfterUpload, options: nil)
        requireConfirmationOption.bind("value", toObject: defaults, withKeyPath: kRequiresUploadConfirmation, options: nil)
        resizeScreenshotsOption.bind("value", toObject: defaults, withKeyPath: kResizeScreenshots, options: nil)
        
        // Hide screenshot resizing option if a retina display is not detected
        resizeScreenshotsOption.hidden = !hasRetinaDisplay
        
        // Add menu to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        statusItem.menu = menu
        statusItem.toolTip = "mac2imgur"
        updateStatusIcon(false)
        
        // Enable drag and drop upload if OS X >= 10.10
        if NSAppKitVersionNumber >= Double(NSAppKitVersionNumber10_10) {
            statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
            statusItem.button?.window?.delegate = self
        }
        
        // Start monitoring for screenshots
        monitor = ScreenshotMonitor(callback: screenshotDetected)
        monitor.startMonitoring()
        
        // Handle the notification supplied if the application has been launched from the notification center
        if let userNotification = aNotification.userInfo?[NSApplicationLaunchUserNotificationKey] as? NSUserNotification {
            userNotificationCenter(NSUserNotificationCenter.defaultUserNotificationCenter(), didActivateNotification: userNotification)
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        monitor.stopMonitoring()
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
    }
    
    func screenshotDetected(imagePath: String) {
        // Check that screenshot detection has not been disabled
        if !defaults.boolForKey(kDisableScreenshotDetection) && hasUploadConfirmation(imagePath) {
            updateStatusIcon(true)
            let upload = ImgurUpload(imagePath: imagePath, isScreenshot: true, callback: uploadAttemptCompleted)
            // Resize the screenshot if necessary
            if defaults.boolForKey(kResizeScreenshots) && hasRetinaDisplay {
                upload.resizeImage(1 / NSScreen.mainScreen()!.backingScaleFactor)
            }
            imgurClient.addToQueue(upload)
        }
    }
    
    func uploadAttemptCompleted(upload: ImgurUpload) {
        updateStatusIcon(false)
        let type = upload.isScreenshot ? "Screenshot" : "Image"
        if upload.successful {
            copyToClipboard(upload.link!)
            displayNotification("\(type) uploaded successfully!", informativeText: upload.link!)
            
            if upload.isScreenshot && defaults.boolForKey(kDeleteScreeenshotAfterUpload) {
                deleteFile(upload.imagePath)
            }
        } else {
            displayNotification("\(type) upload failed...", informativeText: upload.error ?? "")
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        if let URL = NSURL(string: notification.informativeText!) {
            NSWorkspace.sharedWorkspace().openURL(URL)
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func menuWillOpen(menu: NSMenu) {
        // Set account menu item to relevant title
        accountItem.title = imgurClient.isAuthenticated ? "Sign Out (\(imgurClient.username!))" : "Sign in..."
        
        // Set launch at login menu option to current state
        launchAtLoginOption.state = LaunchServicesHelper.applicationIsInStartUpItems ? NSOnState : NSOffState
    }
    
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        // Ensure that the dragged files are images
        if let files = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? [String] {
            for file in files {
                if !contains(imgurAllowedFileTypes, file.pathExtension) {
                    return NSDragOperation.None
                }
            }
        }
        return NSDragOperation.Copy
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let filePaths = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? [String] {
            for filePath in filePaths {
                let upload = ImgurUpload(imagePath: filePath, isScreenshot: false, callback: uploadAttemptCompleted)
                imgurClient.addToQueue(upload)
                updateStatusIcon(true)
            }
            return true
        }
        return false
    }
    
    func handleURLEvent(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        // Attempt to parse response URL
        if let URLString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            let URL = NSURL(string: URLString)!
            if let query = URL.query?.componentsSeparatedByString("&") {
                var params = [String: String]()
                for param in query {
                    let elts = param.componentsSeparatedByString("=")
                    if elts.count == 2 {
                        params[elts[0]] = elts[1]
                    }
                }
                if let code = params["code"] {
                    imgurClient.requestRefreshTokens(code, callback: { () -> () in
                        self.displayNotification("Authentication successful", informativeText: "Signed in as \(self.imgurClient.username!)")
                    })
                }
            }
        }
    }
    
    // Selector methods
    
    @IBAction func selectImages(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.title = "Select Images"
        panel.prompt = "Upload"
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = imgurAllowedFileTypes
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
        } else {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://api.imgur.com/oauth2/authorize?client_id=\(imgurClientId)&response_type=code")!)
        }
    }
    
    @IBAction func launchAtLoginAction(sender: NSMenuItem) {
        LaunchServicesHelper.toggleLaunchAtStartup()
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
    
    func deleteFile(filePath: String) {
        var error: NSError?
        NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
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
    
    func hasUploadConfirmation(imagePath: String) -> Bool {
        if defaults.boolForKey(kRequiresUploadConfirmation) {
            let alert = NSAlert()
            alert.messageText = "Do you want to upload this screenshot?"
            alert.informativeText = "\"\(imagePath.lastPathComponent.stringByDeletingPathExtension)\" will be uploaded to imgur.com, where it is publicly accessible."
            alert.addButtonWithTitle("Upload")
            alert.addButtonWithTitle("Cancel")
            if alert.runModal() == NSAlertSecondButtonReturn {
                return false
            }
        }
        return true
    }
    
    var hasRetinaDisplay: Bool {
        return NSScreen.mainScreen()?.backingScaleFactor > 1
    }
}