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
    var callback: (pathToImage: String) -> ()
    var blacklist: [String] = []
    
    init(callback: (pathToImage: String) -> ()) {
        self.callback = callback
        
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
        if query.resultCount > 0 {
            
            for metadataItem: NSMetadataItem in (query.results as [NSMetadataItem]) {
                // Check that the screenshot is actually new
                if !contains(blacklist, (metadataItem.valueForKey(NSMetadataItemPathKey) as String).lastPathComponent.stringByDeletingPathExtension) {
                    
                    println("NSMetadataItem: \(metadataItem.description)")
                    
                    // Get the path to the screenshot
                    var screenshotPath: String = metadataItem.valueForKey(NSMetadataItemPathKey) as String
                    
                    println("Screenshot file event detected @ \(screenshotPath)")
                    
                    // Notify the delegate with the path to the screenshot
                    callback(pathToImage: screenshotPath)
                    
                    // Add uploaded screenshot to blacklist
                    addToBlacklist(screenshotPath)
                }
            }
        }
    }
    
    @objc func initialiseBlacklist() {
        if query.resultCount > 0 {
            for metadataItem: NSMetadataItem in (query.results as [NSMetadataItem]) {
                addToBlacklist(metadataItem.valueForKey(NSMetadataItemPathKey) as String)
            }
        }
        println("Blacklist size = \(blacklist.count)")
    }
    
    func addToBlacklist(screenshotPath: String) {
        blacklist.append(screenshotPath.lastPathComponent.stringByDeletingPathExtension)
    }
}