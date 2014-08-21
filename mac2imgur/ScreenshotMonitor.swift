//
//  ScreenshotMonitor.swift
//  mac2imgur
//

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