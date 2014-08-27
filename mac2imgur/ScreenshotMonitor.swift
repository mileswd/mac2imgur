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
    var blacklist: [String] = []
    
    init(delegate: ScreenshotMonitorDelegate) {
        self.delegate = delegate
        
        query = NSMetadataQuery()
        
        // Only accept screenshots
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1", argumentArray: nil)
        
        // Add observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("initialiseBlacklist"), name: NSMetadataQueryDidFinishGatheringNotification, object: query)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("eventOccurred"), name: NSMetadataQueryDidUpdateNotification, object: query)
        
        // Start query
        query.startQuery()
    }
    
    @objc func eventOccurred() {
        
        let resultCount: Int = query.resultCount
        
        if isDeletion() || resultCount <= 0 {
            
            // TODO: Make a loop for finding only the item missing and deleting it from blacklist
            NSLog("Screenshot has been deleted")
        
        } else {
            
            NSLog("RESULTCOUNT: \(resultCount)")
            
            if resultCount > 0 {
                
                var metadataItem: NSMetadataItem? = query.resultAtIndex(query.resultCount - 1) as NSMetadataItem?
                
                NSLog("NSMetadataItem: \(metadataItem?.description!)")
                
                // Get the path to the screenshot
                var screenshotPath: String = metadataItem!.valueForKey(NSMetadataItemPathKey) as String
                
                println("Screenshot file event detected @ \(screenshotPath)")
                
                // Check that the screenshot is actually new
                if !contains(blacklist, screenshotPath.lastPathComponent.stringByDeletingPathExtension) {
                    // Notify the delegate with the path to the screenshot
                    delegate.screenshotEventOccurred(screenshotPath)
                } else {
                    println("Ignoring screenshot @ \(screenshotPath) as it is not a new screenshot")
                }
                
                // Add uploaded screenshot to blacklist
                addToBlacklist(screenshotPath)
            }
        }
    }
    
    @objc func initialiseBlacklist() {
        if query.resultCount > 0 {
            for element: NSMetadataItem? in (query.results as [NSMetadataItem]) {
                addToBlacklist(element!.valueForKey(NSMetadataItemPathKey) as String)
            }
        }
        NSLog("BLACKLIST SIZE \(blacklist.count)")
    }
    
    func addToBlacklist(screenshotPath: String) {
        blacklist.append(screenshotPath.lastPathComponent.stringByDeletingPathExtension)
    }
    
    
    func removeFromBlackList(screenshotPath: String){
        var indexOfScreenshot: NSInteger?
        
        for index in 0..<query.resultCount {
            if blacklist[index] == screenshotPath {
                indexOfScreenshot = index
            }
        }
        
        if indexOfScreenshot != nil {
            blacklist.removeAtIndex(indexOfScreenshot!)
        }

    }
    
    func isDeletion() -> Bool {
        
        return query.resultCount < blacklist.count
        
    }
    
    func stop() {
        query.stopQuery()
    }
    
}

protocol ScreenshotMonitorDelegate {
    func screenshotEventOccurred(pathToImage: String) -> ()
}