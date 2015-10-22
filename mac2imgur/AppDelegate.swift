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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, NSURLSessionDataDelegate {
    
    @IBOutlet weak var interfaceHelper: InterfaceHelper!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var imgurClient = ImgurClient()
    var monitor: ScreenshotMonitor!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        defaults.registerDefaults(["NSApplicationCrashOnExceptions": true])
        
        // Crashlytics integration
        Fabric.with([Crashlytics.self])
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: "handleURLEvent:withReplyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        // Handle the notification supplied if the application has been launched from the notification center
        if let userNotification = aNotification.userInfo?[NSApplicationLaunchUserNotificationKey] as? NSUserNotification {
            userNotificationCenter(NSUserNotificationCenter.defaultUserNotificationCenter(), didActivateNotification: userNotification)
        }
        
        // Start monitoring for screenshots
        monitor = ScreenshotMonitor(callback: { (screenshotURL) -> Void in
            let imgurUpload = ImgurUpload(imageURL: screenshotURL, isScreenshot: true)
            self.upload(imgurUpload)
        })
        monitor.startMonitoring()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        monitor.stopMonitoring()
        NSStatusBar.systemStatusBar().removeStatusItem(interfaceHelper.statusItem)
    }
    
    func upload(imgurUpload: ImgurUpload) {
        if imgurUpload.isScreenshot {
            if defaults.boolForKey(kDisableScreenshotDetection) {
                // Screenshot detection is disabled
                return
            }
            
            if !interfaceHelper.hasUploadConfirmation(imgurUpload){
                return
            }
            
            // Resize the screenshot if necessary
            if defaults.boolForKey(kResizeScreenshots) {
                imgurUpload.downscaleRetinaImage()
            }
            
            // Clear the pasteboard if necessary
            if defaults.boolForKey(kClearClipboard) {
                NSPasteboard.generalPasteboard().clearContents()
            }
        }
        imgurUpload.completionHandler = uploadAttemptCompleted
        imgurClient.addToQueue(imgurUpload)
        interfaceHelper.updateStatusIcon(true)
    }
    
    func uploadAttemptCompleted(upload: ImgurUpload) {
        interfaceHelper.updateStatusIcon(false)
        
        let type = upload.isScreenshot ? "Screenshot" : "Image"
        
        if let link = upload.link {
            // Upload was successful
            interfaceHelper.addRecentUpload(upload)
            Utils.copyToClipboard(link)
            Utils.displayNotification("\(type) Upload Succeeded", informativeText: link)
            
            if upload.isScreenshot && defaults.boolForKey(kDeleteScreenshotAfterUpload) {
                Utils.deleteFile(upload.imageURL)
            }
            
        } else {
            Utils.displayNotification("\(type) Upload Failed", informativeText: upload.error ?? "")
        }
    }
    
    func handleURLEvent(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        // Attempt to parse response URL
        guard let URLString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue else {
            NSLog("Unable to determine URL from AppleEvent")
            return
        }
        
        guard let query = NSURL(string: URLString)?.query?.componentsSeparatedByString("&") else {
            NSLog("Unable to find URL query component")
            return
        }
        
        var parameters = [String: String]()
        for parameter in query {
            let pair = parameter.componentsSeparatedByString("=")
            if pair.count == 2 {
                parameters[pair[0]] = pair[1]
            }
        }
        
        if let code = parameters["code"] {
            imgurClient.requestRefreshToken(code, callback: { (authError: String?) -> Void in
                if let error = authError {
                    Utils.displayNotification("Authentication Failed", informativeText: error)
                } else {
                    Utils.displayNotification("Authentication Succeeded", informativeText: "Signed in as \(self.imgurClient.username!)")
                }
            })
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        // Open URL if present in the informativeText field of a notification
        if let text = notification.informativeText {
            Utils.openURL(text)
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        // Always show notifications
        return true
    }
}