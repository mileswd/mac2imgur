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
    
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var accountAuthItem: NSMenuItem!
    @IBOutlet weak var accountWebItem: NSMenuItem!
    @IBOutlet weak var deleteAfterUploadPreference: NSMenuItem!
    @IBOutlet weak var disableDetectionPreference: NSMenuItem!
    @IBOutlet weak var requireConfirmationPreference: NSMenuItem!
    @IBOutlet weak var resizeScreenshotsPreference: NSMenuItem!
    @IBOutlet weak var launchAtLoginPreference: NSMenuItem!
    
    var statusItem: NSStatusItem!
    var imgurClient: ImgurClient!
    var upload: ((imagePath: String) -> Void)!
    var uploadCount = 0
    
    /// Setup all interface components, including the status bar item and menu
    func setup(upload: (imagePath: String) -> Void, imgurClient: ImgurClient) {
        self.imgurClient = imgurClient
        self.upload = upload
        
        // Bind menu items to user defaults controller
        disableDetectionPreference.bind("value", toObject: defaults, withKeyPath: kDisableScreenshotDetection, options: nil)
        deleteAfterUploadPreference.bind("value", toObject: defaults, withKeyPath: kDeleteScreenshotAfterUpload, options: nil)
        resizeScreenshotsPreference.bind("value", toObject: defaults, withKeyPath: kResizeScreenshots, options: nil)
        
        // Add menu to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        statusItem.menu = menu
        statusItem.toolTip = "mac2imgur"
        statusItem.image = inactiveIcon
        
        // Enable drag and drop upload if OS X >= 10.10
        if NSAppKitVersionNumber >= Double(NSAppKitVersionNumber10_10) {
            statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
            statusItem.button?.window?.delegate = self
        }
    }
    
    func updateStatusIcon(uploadInProgress: Bool) {
        uploadInProgress ? uploadCount++ : uploadCount--
        statusItem.image = uploadCount == 0 ? inactiveIcon : activeIcon
    }
    
    func menuWillOpen(menu: NSMenu) {
        // Set account menu item to relevant title
        accountAuthItem.title = imgurClient.isAuthenticated ? "Sign Out (\(imgurClient.username!))" : "Sign in..."
        
        // Hide account web action if not authenticated
        accountWebItem.hidden = !imgurClient.isAuthenticated
        
        // Set launch at login menu option to current state
        launchAtLoginPreference.state = launchServicesHelper.applicationIsInStartUpItems ? NSOnState : NSOffState
        
        // Hide screenshot resizing preference if a retina display is not detected
        resizeScreenshotsPreference.hidden = NSScreen.mainScreen()?.backingScaleFactor <= 1
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
                upload(imagePath: filePath)
            }
            return true
        }
        return false
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func selectImagesAction(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.title = "Select Images"
        panel.prompt = "Upload"
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = imgurAllowedFileTypes
        if panel.runModal() == NSOKButton {
            for imageURL in panel.URLs {
                upload(imagePath: (imageURL as! NSURL).path!)
            }
        }
    }
    
    @IBAction func accountAuthAction(sender: NSMenuItem) {
        if imgurClient.isAuthenticated {
            defaults.removeObjectForKey(kUsername)
            defaults.removeObjectForKey(kRefreshToken)
            imgurClient.deauthenticate()
        } else {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://api.imgur.com/oauth2/authorize?client_id=\(imgurClientId)&response_type=code")!)
        }
    }
    
    @IBAction func accountWebAction(sender: NSMenuItem) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://\(imgurClient.username!).imgur.com/all/")!)
    }
    
    @IBAction func launchAtLoginAction(sender: NSMenuItem) {
        launchServicesHelper.toggleLaunchAtStartup()
    }
    
    @IBAction func aboutAction(sender: NSMenuItem) {
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        NSApplication.sharedApplication().orderFrontStandardAboutPanel(sender)
    }
}
