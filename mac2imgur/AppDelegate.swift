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
    var imgurClient: ImgurClient!
    var monitor: ScreenshotMonitor!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        defaults.registerDefaults(["NSApplicationCrashOnExceptions": true])
        
        // Crashlytics integration
        Fabric.with([Crashlytics()])
        
        // Setup Imgur client
        imgurClient = ImgurClient(username: defaults.stringForKey(kUsername), refreshToken: defaults.stringForKey(kRefreshToken))
        
        // Setup user interface
        interfaceHelper.setup(manualUpload, imgurClient: imgurClient)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: "handleURLEvent:withReplyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        // Handle the notification supplied if the application has been launched from the notification center
        if let userNotification = aNotification.userInfo?[NSApplicationLaunchUserNotificationKey] as? NSUserNotification {
            userNotificationCenter(NSUserNotificationCenter.defaultUserNotificationCenter(), didActivateNotification: userNotification)
        }
        
        // Start monitoring for screenshots
        monitor = ScreenshotMonitor(callback: screenshotDetected)
        monitor.startMonitoring()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        monitor.stopMonitoring()
        NSStatusBar.systemStatusBar().removeStatusItem(interfaceHelper.statusItem)
    }
    
    func manualUpload(imagePath: String) {
        let upload = ImgurUpload(imagePath: imagePath, isScreenshot: false)
        upload.initiationHandler = uploadAttemptInitiated
        upload.completionHandler = uploadAttemptCompleted
        imgurClient.addToQueue(upload)
    }
    
    func screenshotDetected(imagePath: String) {
        if !defaults.boolForKey(kDisableScreenshotDetection) {
            let upload = ImgurUpload(imagePath: imagePath, isScreenshot: true)
            upload.initiationHandler = uploadAttemptInitiated
            upload.completionHandler = uploadAttemptCompleted
            // Resize the screenshot if necessary
            if defaults.boolForKey(kResizeScreenshots) &&  NSScreen.mainScreen()?.backingScaleFactor > 1 {
                upload.resizeImage(1 / NSScreen.mainScreen()!.backingScaleFactor)
            }
            imgurClient.addToQueue(upload)
        }
    }
    
    func uploadAttemptInitiated(upload: ImgurUpload) {
        interfaceHelper.updateStatusIcon(true)
    }
    
    func uploadAttemptCompleted(upload: ImgurUpload) {
        interfaceHelper.updateStatusIcon(false)
        let type = upload.isScreenshot ? "Screenshot" : "Image"
        if upload.successful {
            Utils.copyToClipboard(upload.link!)
            Utils.displayNotification("\(type) uploaded successfully!", informativeText: upload.link!)
            if upload.isScreenshot && defaults.boolForKey(kDeleteScreenshotAfterUpload) {
                Utils.deleteFile(upload.imagePath)
            }
        } else {
            Utils.displayNotification("\(type) upload failed...", informativeText: upload.error ?? "")
        }
    }
    
    func handleURLEvent(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        // Attempt to parse response URL
        if let URLString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            let URL = NSURL(string: URLString)!
            if let query = URL.query?.componentsSeparatedByString("&") {
                var parameters = [String: String]()
                for parameter in query {
                    let pair = parameter.componentsSeparatedByString("=")
                    if pair.count == 2 {
                        parameters[pair[0]] = pair[1]
                    }
                }
                if let code = parameters["code"] {
                    imgurClient.authenticate(code, callback: { (username: String, refreshToken: String) -> Void in
                        self.defaults.setObject(username, forKey: kUsername)
                        self.defaults.setObject(refreshToken, forKey: kRefreshToken)
                        Utils.displayNotification("Authentication successful", informativeText: "Signed in as \(username)")
                    })
                }
            }
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        // Open URL if present in the informativeText field of a notification
        if let URL = NSURL(string: notification.informativeText!) {
            NSWorkspace.sharedWorkspace().openURL(URL)
        }
    }
    
    // Always show notifications
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}