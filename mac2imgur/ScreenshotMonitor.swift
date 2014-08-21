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

class ScreenshotMonitor {
    
    var query: NSMetadataQuery
    var delegate: ScreenshotMonitorDelegate
    
    init(delegate: ScreenshotMonitorDelegate) {
        self.delegate = delegate
        
        query = NSMetadataQuery()
        
        // Only accept screenshots
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1", argumentArray: nil)
        
        // Add the observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("eventOccurred:"), name: NSMetadataQueryDidUpdateNotification, object: query)
        
        // Start query
        query.startQuery()
    }
    
    @objc func eventOccurred(notification: NSNotification) {
        // Get the latest NSMetadataItem
        var metadataItem: NSMetadataItem = query.resultAtIndex(query.resultCount - 1) as NSMetadataItem
        
        // Get the path to the screenshot
        var screenshotPath = metadataItem.valueForKey(NSMetadataItemPathKey) as String
        
        // Notify the delegate with the path to the screenshot
        println("Screenshot detected @ \(screenshotPath)")
        
        delegate.screenshotEventOccurred(screenshotPath)
    }
    
    func stop() {
        query.stopQuery()
    }
    
}

protocol ScreenshotMonitorDelegate {
    func screenshotEventOccurred(pathToImage: String) -> ()
}