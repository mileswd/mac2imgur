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
    
    var query: NSMetadataQuery
    var delegate: ScreenshotMonitorDelegate
    var blacklist: [String]
    
    init(delegate: ScreenshotMonitorDelegate) {
        self.delegate = delegate
        self.blacklist = []
        
        query = NSMetadataQuery()
        
        // Only accept screenshots
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1", argumentArray: nil)
        
        // Add observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("eventOccurred:"), name: NSMetadataQueryDidUpdateNotification, object: query)
        
        // Start query
        query.startQuery()
    }
    
    @objc func eventOccurred(notification: NSNotification) {
        if let info = notification.userInfo {
            if let itemsAdded = info["kMDQueryUpdateAddedItems"] as? NSArray {
                for item in itemsAdded {
                    let metadataItem = item as NSMetadataItem
                    
                    // Get the path to the screenshot
                    let screenshotPath: String = metadataItem.valueForKey(NSMetadataItemPathKey) as String
                    let screenshotName: String = screenshotPath.lastPathComponent.stringByDeletingPathExtension
                    
                    // Ensure that the screenshot detected is from the right folder and isn't blacklisted
                    if screenshotPath.stringByDeletingLastPathComponent.stringByStandardizingPath == getScreenshotDirectory().stringByStandardizingPath && !contains(blacklist, screenshotName) {
                        println("Screenshot file event detected @ \(screenshotPath)")
                        delegate.screenshotDetected(screenshotPath)
                        blacklist.append(screenshotName)
                    }
                }
            }
        }
    }
    
    func getScreenshotDirectory() -> String {
        if let dir = NSUserDefaults.standardUserDefaults().persistentDomainForName("com.apple.screencapture")?["location"] as? String {
            var isDir: ObjCBool = false
            if NSFileManager.defaultManager().fileExistsAtPath(dir, isDirectory: &isDir) {
                return dir
            }
        }
        return NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)[0] as String
    }
}

protocol ScreenshotMonitorDelegate {
    func screenshotDetected(pathToImage: String)
}