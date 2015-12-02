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

class ScreenshotMonitor {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let fileManager = NSFileManager.defaultManager()
    let screencaptureDomain = "com.apple.screencapture"
    
    let callback: NSURL -> Void
    var eventStream: FSEventStreamRef?
    
    init(callback: NSURL -> Void) {
        self.callback = callback
    }
    
    func startMonitoring() {
        guard let path = screenshotDirectoryURL?.path else {
            NSLog("Unable to get screenshot directory")
            return
        }
        
        let streamCallback: FSEventStreamCallback = {
            (streamRef: ConstFSEventStreamRef,
            clientCallBackInfo: UnsafeMutablePointer<Void>,
            numEvents: Int,
            eventPaths: UnsafeMutablePointer<Void>,
            eventFlags: UnsafePointer<FSEventStreamEventFlags>,
            eventIds: UnsafePointer<FSEventStreamEventId>) in
            
            guard let eventPaths = unsafeBitCast(eventPaths, NSArray.self) as? [String] else {
                NSLog("Unable to get eventPaths")
                return
            }
            
            for path in eventPaths {
                unsafeBitCast(clientCallBackInfo, ScreenshotMonitor.self).handleEvent(path)
            }
        }
        
        var streamContext = FSEventStreamContext(
            version: 0,
            info: UnsafeMutablePointer<Void>(unsafeAddressOf(self)),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        let eventStream = FSEventStreamCreate(
            nil,
            streamCallback,
            &streamContext,
            [path],
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        )
        
        self.eventStream = eventStream
        
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
        FSEventStreamStart(eventStream)
    }
    
    
    func stopMonitoring() {
        if let eventStream = eventStream {
            FSEventStreamStop(eventStream)
            FSEventStreamInvalidate(eventStream)
        }
    }
    
    func handleEvent(path: String) {
        guard let attributes = try? fileManager.attributesOfItemAtPath(path) else {
            return // Unable to get file attributes
        }
        
        guard let extendedAttributes = attributes["NSFileExtendedAttributes"] as? [String: AnyObject] else {
            return // Unable to get extended attributes
        }
        
        if !extendedAttributes.keys.contains("com.apple.metadata:kMDItemIsScreenCapture") {
            return // File is not a screenshot
        }
        
        guard let creationDate = attributes[NSFileCreationDate] as? NSDate else {
            return // Unable to get creation date
        }
        
        if creationDate.timeIntervalSinceNow < -5 {
            return // File is more than 5 seconds old - probably not a new screenshot
        }
        
        callback(NSURL(fileURLWithPath: path))
    }
    
    var screenshotDirectoryURL: NSURL? {
        // Check for custom screenshot location chosen by user
        if let customPath = defaults.persistentDomainForName(screencaptureDomain)?["location"] as? NSString {
            let standardizedPath = customPath.stringByStandardizingPath
            
            // Check that the chosen directory exists, otherwise screencapture will not use it
            var isDir = ObjCBool(false)
            if fileManager.fileExistsAtPath(standardizedPath, isDirectory: &isDir) && isDir {
                return NSURL(fileURLWithPath: standardizedPath)
            }
        }
        
        // If a custom location is not defined (or invalid) return the default screenshot location (~/Desktop)
        return fileManager.URLsForDirectory(.DesktopDirectory, inDomains: .UserDomainMask).first
    }
}