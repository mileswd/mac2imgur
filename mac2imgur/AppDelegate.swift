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

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, ImgurUploadDelegate, ScreenshotMonitorDelegate {
    
    @IBOutlet var window: NSWindow?
    var statusItem: NSStatusItem?
    var monitor: ScreenshotMonitor?
    var lastLink: String = ""
    var preferencesController: PreferencesWindowController?
    var imgurSession: ImgurClient! = ImgurClient()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        println("Launching mac2imgur")
        
        // Create menu
        let menu = NSMenu()
        menu.addItemWithTitle("Copy last link", action: NSSelectorFromString("copyLinkToClipboard"), keyEquivalent: "c")
        menu.addItemWithTitle("Open Preferences", action: NSSelectorFromString("showPreferences"), keyEquivalent: "p")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Quit", action: NSSelectorFromString("quit"), keyEquivalent: "q")
        menu.autoenablesItems = false
        
        // Add to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(-1))
        statusItem!.highlightMode = true
        statusItem!.menu = menu
        statusItem!.alternateImage = NSImage(named: "Active_Inverted")
        updateStatusIcon(false)
        statusItem!.toolTip = "mac2imgur"
        
        // Setup screenshot monitor
        monitor = ScreenshotMonitor(delegate: self)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    func uploadAttemptCompleted(successful: Bool, link: String, pathToImage: String) {
        if successful {
            lastLink = link
            copyLinkToClipboard()
            displayNotification("Screenshot uploaded successfully!", informativeText: lastLink)
            
            if imgurSession.deleteScreenshotAfterUpload! {
                deleteScreenshot(pathToImage)
            }
            
        } else {
            displayNotification("Screenshot upload failed...", informativeText: "")
        }
        updateStatusIcon(false)
    }
    
    func screenshotEventOccurred(pathToImage: String) {
        let upload = UploadController(pathToImage: pathToImage, client: imgurSession, delegate: self)
        upload.attemptUpload()
        updateStatusIcon(true)
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
    
    func deleteScreenshot(pathToImage: String!){
        let fileManager = NSFileManager.defaultManager()
        var error: NSError?
        fileManager.removeItemAtPath(pathToImage, error: &error)
        if error != nil {
            NSLog(error!.localizedDescription)
        }
        
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
    
    func updateStatusIcon(isActive: Bool) {
        if isActive {
            statusItem!.image = NSImage(named: "Active")
        } else {
            statusItem!.image = NSImage(named: "Inactive")
        }
    }
    
    func showPreferences(){
        preferencesController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesController?.imgurSession = self.imgurSession
        preferencesController?.showWindow(self)

        
    }
    
}