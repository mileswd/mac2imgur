//
//  AppDelegate.swift
//  mac2imgur
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, AnonymousImgurUploadDelegate, ScreenshotMonitorDelegate {
    
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
        statusItem!.image = NSImage(named: "Status")
        statusItem!.alternateImage = NSImage(named: "Status_Inverted")
        statusItem!.toolTip = "mac2imgur"
        
        // Setup screenshot monitor
        monitor = ScreenshotMonitor(delegate: self)
        
    }
    
    func uploadAttemptCompleted(successful: Bool, link: String) {
        if successful {
            lastLink = link
            copyLinkToClipboard()
            displayNotification("Screenshot uploaded successfully!", informativeText: lastLink)
        } else {
            displayNotification("Screenshot upload failed...", informativeText: "")
        }
    }
    
    func screenshotEventOccurred(pathToImage: String) {
        let upload = AnonymousImgurUpload(pathToImage: pathToImage, delegate: self)
        upload.attemptUpload()
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
    
}