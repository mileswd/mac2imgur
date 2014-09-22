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

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet var window: NSWindow?
    var statusItem: NSStatusItem?
    var monitor: ScreenshotMonitor?
    var preferencesController: PreferencesWindowController?
    var prefs: PreferencesManager?
    var imgurSession: ImgurClient?
    var lastLink: String = ""
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        println("Launching mac2imgur")
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        prefs = PreferencesManager()
        imgurSession = ImgurClient(prefs: prefs!)
        
        // Setup screenshot monitor & upload function
        monitor = ScreenshotMonitor(callback: { (pathToImage) -> () in
            let upload = UploadController(pathToImage: pathToImage, client: self.imgurSession!, callback: { (successful, link, pathToImage) -> () in
                if successful {
                    self.lastLink = link
                    self.copyLinkToClipboard()
                    self.displayNotification("Screenshot uploaded successfully!", informativeText: self.lastLink)
                    
                    if self.prefs!.getBool(PreferencesConstant.deleteScreenshotAfterUpload.rawValue, def: false){
                        self.deleteScreenshot(pathToImage)
                    }
                } else {
                    self.displayNotification("Screenshot upload failed...", informativeText: "")
                }
                self.updateStatusIcon(false)
            })
            upload.attemptUpload()
            self.updateStatusIcon(true)
        })
        
        // Create menu
        let menu = NSMenu()
        menu.addItemWithTitle("Copy last link", action: NSSelectorFromString("copyLinkToClipboard"), keyEquivalent: "")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Preferences...", action: NSSelectorFromString("showPreferences"), keyEquivalent: "")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("About mac2imgur", action: NSSelectorFromString("orderFrontStandardAboutPanel:"), keyEquivalent: "")
        menu.addItemWithTitle("Quit", action: NSSelectorFromString("terminate:"), keyEquivalent: "")
        menu.autoenablesItems = false
        
        // Add to status bar
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        statusItem!.highlightMode = true
        statusItem!.menu = menu
        statusItem!.alternateImage = NSImage(named: "Active_Inverted")
        statusItem!.toolTip = "mac2imgur"
        updateStatusIcon(false)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification!) {
        if notification.informativeText != "" {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: notification.informativeText!))
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        monitor?.query.stopQuery()
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
        preferencesController?.imgurSession = imgurSession
        preferencesController?.prefs = prefs
        preferencesController?.showWindow(self)
    }
    
}