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

import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, AnonymousImgurUploadDelegate, ScreenshotMonitorDelegate {
    
    @IBOutlet var window: NSWindow?
    var statusItem: NSStatusItem?
    var monitor: ScreenshotMonitor?
    var lastLink: String = ""
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        println("Launching mac2imgur")
        
        // Create menu
        let menu = NSMenu()
        menu.addItemWithTitle("Copy last link", action: NSSelectorFromString("copyLinkToClipboard"), keyEquivalent: "c")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Quit", action: NSSelectorFromString("quit"), keyEquivalent: "q")
        menu.autoenablesItems = false
        
        // Add to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(-1))
        statusItem!.highlightMode = true
        statusItem!.menu = menu
        statusItem!.alternateImage = NSImage(named: "Status_Inverted")
        setInactiveStatus()
        statusItem!.toolTip = "mac2imgur"
        
        // Setup screenshot monitor
        monitor = ScreenshotMonitor(delegate: self)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
    }
    
    func uploadAttemptCompleted(successful: Bool, link: String) {
        if successful {
            lastLink = link
            copyLinkToClipboard()
            displayNotification("Screenshot uploaded successfully!", informativeText: lastLink)
        } else {
            displayNotification("Screenshot upload failed...", informativeText: "")
        }
        setInactiveStatus()
    }
    
    func screenshotEventOccurred(pathToImage: String) {
        let upload = AnonymousImgurUpload(pathToImage: pathToImage, delegate: self)
        upload.attemptUpload()
        setUploadingStatus()
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification!) {
        if notification.informativeText != "" {
            NSWorkspace.sharedWorkspace().openURL(NSURL.URLWithString(notification.informativeText))
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        monitor?.stop()
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
    }
    
    func copyLinkToClipboard() {
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.setString(lastLink, forType: NSStringPboardType)
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func displayNotification(title: String, informativeText: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = informativeText
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    func setUploadingStatus(){
        statusItem!.image = NSImage(named: "Status")

    }
    
    func setInactiveStatus(){
        statusItem!.image = NSImage(named: "Inactive")
    }
    
}