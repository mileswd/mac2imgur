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

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, ScreenshotMonitorDelegate, UploadControllerDelegate {
    
    var prefs: PreferencesManager!
    var imgurClient: ImgurClient!
    var monitor: ScreenshotMonitor!
    var statusItem: NSStatusItem!
    var lastLink: String = ""
    var preferencesController: PreferencesWindowController?
    
    // Delegate methods
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        NSApp.activateIgnoringOtherApps(true)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        prefs = PreferencesManager()
        imgurClient = ImgurClient(preferences: prefs)
        
        // Start monitoring for screenshots
        monitor = ScreenshotMonitor(delegate: self)
        
        // Create menu
        let menu = NSMenu()
        menu.addItemWithTitle("Copy last link", action: NSSelectorFromString("copyLastLinkToClipboard"), keyEquivalent: "")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Preferences...", action: NSSelectorFromString("showPreferences"), keyEquivalent: "")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("About mac2imgur", action: NSSelectorFromString("orderFrontStandardAboutPanel:"), keyEquivalent: "")
        menu.addItemWithTitle("Quit", action: NSSelectorFromString("terminate:"), keyEquivalent: "")
        menu.autoenablesItems = false
        
        // Create status bar icon
        let statusIcon = NSImage(named: "StatusIcon")!
        statusIcon.setTemplate(true)
        
        // Add menu to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        statusItem.menu = menu
        statusItem.button?.image = statusIcon
        statusItem.button?.toolTip = "mac2imgur"
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        monitor.query.stopQuery()
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
    }
    
    func screenshotDetected(pathToImage: String) {
        let upload = ImgurUpload(pathToImage: pathToImage, client: imgurClient, delegate: self)
        upload.attemptUpload()
    }
    
    func screenshotUploadAttemptCompleted(successful: Bool, link: String, pathToImage: String) {
        if successful {
            lastLink = link
            copyToClipboard(lastLink)
            displayNotification("Screenshot uploaded successfully!", informativeText: self.lastLink)
            
            if prefs.getBool(PreferencesConstant.deleteScreenshotAfterUpload.rawValue, def: false){
                println("Deleting screenshot @ \(pathToImage)")
                deleteFile(pathToImage)
            }
        } else {
            displayNotification("Screenshot upload failed...", informativeText: "")
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification!) {
        if notification.informativeText != "" {
            openURL(notification.informativeText!)
        }
    }
    
    // Selector methods
    
    func copyLastLinkToClipboard() {
        copyToClipboard(lastLink)
    }
    
    func showPreferences() {
        preferencesController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesController!.imgurClient = imgurClient
        preferencesController!.prefs = prefs
        preferencesController!.showWindow(self)
    }
    
    // Utility methods
    
    func copyToClipboard(string: String) {
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.setString(string, forType: NSStringPboardType)
    }
    
    func deleteFile(pathToFile: String) {
        var error: NSError?
        NSFileManager.defaultManager().removeItemAtPath(pathToFile, error: &error)
        if error != nil {
            NSLog(error!.localizedDescription)
        }
    }
    
    func openURL(url: String) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
    }
    
    func displayNotification(title: String, informativeText: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = informativeText
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
}