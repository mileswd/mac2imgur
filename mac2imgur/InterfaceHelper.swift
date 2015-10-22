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

class InterfaceHelper: NSObject, NSWindowDelegate, NSMenuDelegate  {
    
    let launchServicesHelper = LaunchServicesHelper()
    let defaults = NSUserDefaults.standardUserDefaults()
    let activeIcon = NSImage(named: "StatusActive")!
    let inactiveIcon = NSImage(named: "StatusInactive")!
    
    @IBOutlet weak var appDelegate: AppDelegate!
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var recentUploadsItem: NSMenuItem!
    @IBOutlet weak var accountAuthItem: NSMenuItem!
    @IBOutlet weak var accountWebItem: NSMenuItem!
    @IBOutlet weak var deleteAfterUploadPreference: NSMenuItem!
    @IBOutlet weak var disableDetectionPreference: NSMenuItem!
    @IBOutlet weak var requiresConfirmationPreference: NSMenuItem!
    @IBOutlet weak var resizeScreenshotsPreference: NSMenuItem!
    @IBOutlet weak var launchAtLoginPreference: NSMenuItem!
    @IBOutlet weak var clearClipboardPreference: NSMenuItem!
    
    var statusItem: NSStatusItem!
    var uploadCount = 0
    
    override func awakeFromNib() {
        // Setup all interface components, including the status bar item and menu
        
        // Bind menu items to user defaults controller
        disableDetectionPreference.bind("value", toObject: defaults, withKeyPath: kDisableScreenshotDetection, options: nil)
        deleteAfterUploadPreference.bind("value", toObject: defaults, withKeyPath: kDeleteScreenshotAfterUpload, options: nil)
        resizeScreenshotsPreference.bind("value", toObject: defaults, withKeyPath: kResizeScreenshots, options: nil)
        requiresConfirmationPreference.bind("value", toObject: defaults, withKeyPath: kRequiresUploadConfirmation, options: nil)
        clearClipboardPreference.bind("value", toObject: defaults, withKeyPath: kClearClipboard, options: nil)
        
        // Add menu to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.menu = menu
        statusItem.toolTip = "mac2imgur"
        statusItem.image = inactiveIcon
        
        // Enable drag and drop upload if OS X >= 10.10
        if #available(OSX 10.10, *) {
            statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
            statusItem.button?.window?.delegate = self
        }
    }
    
    func hasUploadConfirmation(imgurUpload: ImgurUpload) -> Bool {
        if defaults.boolForKey(kRequiresUploadConfirmation) {
            let alert = NSAlert()
            alert.messageText = "Do you want to upload this screenshot?"
            alert.informativeText = "\"\(imgurUpload.imageName)\" will be uploaded to imgur.com, where it is publicly accessible."
            alert.addButtonWithTitle("Upload")
            alert.addButtonWithTitle("Cancel")
            for button in alert.buttons where button.title == "Cancel" {
                button.keyEquivalent = "c"
            }
            
            NSApplication.sharedApplication().activateIgnoringOtherApps(true)
            if alert.runModal() == NSAlertSecondButtonReturn {
                return false
            }
        }
        return true
    }
    
    func updateStatusIcon(uploadInProgress: Bool) {
        uploadInProgress ? uploadCount++ : uploadCount--
        statusItem.image = uploadCount == 0 ? inactiveIcon : activeIcon
    }
    
    func menuWillOpen(menu: NSMenu) {
        // Set account menu item to relevant title
        accountAuthItem.title = appDelegate.imgurClient.isAuthenticated ? "Sign Out (\(appDelegate.imgurClient.username!))" : "Sign in..."
        
        // Hide account web action if not authenticated
        accountWebItem.hidden = !appDelegate.imgurClient.isAuthenticated
        
        // Set launch at login menu option to current state
        launchAtLoginPreference.state = launchServicesHelper.applicationIsInStartUpItems ? NSOnState : NSOffState
        
        // Hide recent uploads menu if it is empty
        recentUploadsItem.hidden = recentUploadsItem.submenu?.itemArray.count == 0
        
        var retinaDisplayDetected = false
        if let screens = NSScreen.screens() {
            for screen in screens where screen.backingScaleFactor > 1 {
                retinaDisplayDetected = true
            }
        }

        // Hide screenshot resizing preference if a retina display is not detected
        resizeScreenshotsPreference.hidden = !retinaDisplayDetected
    }
    
    func addRecentUpload(upload: ImgurUpload) {
        let menuItem = NSMenuItem(title: upload.imageName, action: "recentUploadAction:", keyEquivalent: "")
        let image = NSImage(data: upload.imageData)!
        let scaleFactor = 16 / max(image.size.width, image.size.height)
        let width = round(image.size.width * scaleFactor)
        let height = round(image.size.height * scaleFactor)
        image.size = NSSize(width: width, height: height)
        menuItem.image = image
        menuItem.target = self
        menuItem.representedObject = upload.link
        recentUploadsItem.submenu?.addItem(menuItem)
    }
    
    func recentUploadAction(sender: NSMenuItem) {
        if let URLString = sender.representedObject as? String {
            Utils.openURL(URLString)
        }
    }
    
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        // Ensure that the dragged files are images
        if let filePaths = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? [String] {
            for filePath in filePaths {
                let fileURL = NSURL(fileURLWithPath: filePath)
                if !imgurAllowedFileTypes.contains(fileURL.pathExtension?.lowercaseString ?? "") {
                    return NSDragOperation.None
                }
            }
        }
        return NSDragOperation.Copy
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let filePaths = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? [String] {
            for filePath in filePaths {
                let fileURL = NSURL(fileURLWithPath: filePath)
                uploadImage(fileURL)
            }
            return true
        }
        return false
    }
    
    func uploadImage(imageURL: NSURL) {
        let imgurUpload = ImgurUpload(imageURL: imageURL, isScreenshot: false)
        appDelegate.upload(imgurUpload)
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func selectImagesAction(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.title = "Select Images"
        panel.prompt = "Upload"
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = imgurAllowedFileTypes
        
        panel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                for imageURL in panel.URLs {
                    self.uploadImage(imageURL)
                }
            }
        }
        
        // Show in front of all other applications
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    @IBAction func accountAuthAction(sender: NSMenuItem) {
        if appDelegate.imgurClient.isAuthenticated {
            appDelegate.imgurClient.deauthenticate()
        } else {
            Utils.openURL("https://api.imgur.com/oauth2/authorize?client_id=\(imgurClientId)&response_type=code")
        }
    }
    
    @IBAction func accountWebAction(sender: NSMenuItem) {
        Utils.openURL("https://\(appDelegate.imgurClient.username!).imgur.com/all/")
    }
    
    @IBAction func launchAtLoginAction(sender: NSMenuItem) {
        launchServicesHelper.toggleLaunchAtStartup()
    }
    
    @IBAction func aboutAction(sender: NSMenuItem) {
        NSApplication.sharedApplication().orderFrontStandardAboutPanel(sender)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
}
