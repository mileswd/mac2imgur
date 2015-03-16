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

class ScreenshotMonitor {
    
    let callback: (screenshotPath: String) -> ()
    var query: NSMetadataQuery
    var blacklist: [String]
    
    init(callback: (screenshotPath: String) -> ()) {
        self.callback = callback
        self.blacklist = []
        
        query = NSMetadataQuery()
        
        // Only accept screenshots
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1", argumentArray: nil)
        
        // Add observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("initialPhaseComplete"), name: NSMetadataQueryDidFinishGatheringNotification, object: query)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("liveUpdatePhaseEvent:"), name: NSMetadataQueryDidUpdateNotification, object: query)
        
        // Start query
        query.startQuery()
    }
    
    @objc func initialPhaseComplete() {
        if let itemsAdded = query.results as? [NSMetadataItem] {
            for item in itemsAdded {
                // Get the path to the screenshot
                if let screenshotPath = item.valueForAttribute(NSMetadataItemPathKey) as? String {
                    let screenshotName = screenshotPath.lastPathComponent.stringByDeletingPathExtension
                    
                    // Blacklist the screenshot if it hasn't already been blacklisted
                    if !contains(blacklist, screenshotName) {
                        blacklist.append(screenshotName)
                    }
                }
            }
        }
    }
    
    @objc func liveUpdatePhaseEvent(notification: NSNotification) {
        if let itemsAdded = notification.userInfo?["kMDQueryUpdateAddedItems"] as? [NSMetadataItem] {
            for item in itemsAdded {
                // Get the path to the screenshot
                if let screenshotPath = item.valueForAttribute(NSMetadataItemPathKey) as? String {
                    let screenshotName = screenshotPath.lastPathComponent.stringByDeletingPathExtension
                    
                    // Ensure that the screenshot detected is from the right folder and isn't blacklisted
                    if screenshotPath.stringByDeletingLastPathComponent.stringByStandardizingPath == screenshotLocationPath.stringByStandardizingPath && !contains(blacklist, screenshotName) {
                        println("Screenshot file event detected @ \(screenshotPath)")
                        callback(screenshotPath: screenshotPath)
                        blacklist.append(screenshotName)
                    }
                }
            }
        }
    }
    
    var screenshotLocationPath: String {
        if let dir = NSUserDefaults.standardUserDefaults().persistentDomainForName("com.apple.screencapture")?["location"] as? String {
            var isDir: ObjCBool = false
            if NSFileManager.defaultManager().fileExistsAtPath(dir, isDirectory: &isDir) {
                return dir
            }
        }
        return NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)[0] as! String
    }
}