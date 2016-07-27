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
    
    let fileManager = FileManager.default
    
    let eventHandler: (URL) -> Void
    var eventStream: FSEventStreamRef?
    
    init(eventHandler: (URL) -> Void) {
        self.eventHandler = eventHandler
    }
    
    func startMonitoring() {
        guard let path = screenshotDirectoryURL?.path else {
            NSLog("Failed to get screenshot directory")
            return
        }
        
        let streamCallback: FSEventStreamCallback = {
            (streamRef: ConstFSEventStreamRef,
            clientCallBackInfo: UnsafeMutablePointer<Void>?,
            numEvents: Int,
            eventPaths: UnsafeMutablePointer<Void>,
            eventFlags: UnsafePointer<FSEventStreamEventFlags>?,
            eventIds: UnsafePointer<FSEventStreamEventId>?) in
            
            guard let eventPaths = Unmanaged<NSArray>
                .fromOpaque(eventPaths)
                .takeUnretainedValue() as? [String] else {
                    NSLog("Failed to get eventPaths")
                    return
            }
            
            guard let clientCallBackInfo = clientCallBackInfo else {
                NSLog("Failed to get clientCallBackInfo")
                return
            }
            
            let screenshotMonitor = Unmanaged<ScreenshotMonitor>
                .fromOpaque(clientCallBackInfo)
                .takeUnretainedValue()
            
            eventPaths.forEach {
                screenshotMonitor.handleEvent(withPath: $0)
            }
        }
        
        var streamContext = FSEventStreamContext(
            version: 0,
            info: UnsafeMutablePointer<Void>(unsafeAddress(of: self)),
            retain: nil,
            release: nil,
            copyDescription: nil)
        
        guard let eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            streamCallback,
            &streamContext,
            [path],
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes
                | kFSEventStreamCreateFlagIgnoreSelf
                | kFSEventStreamCreateFlagFileEvents))
            else {
                NSLog("Failed to create eventStream")
                return
        }
        
        self.eventStream = eventStream
        
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(eventStream)
    }
    
    func stopMonitoring() {
        if let eventStream = eventStream {
            FSEventStreamStop(eventStream)
            FSEventStreamInvalidate(eventStream)
            FSEventStreamRelease(eventStream)
        }
    }
    
    func recentScreenshotExists(atPath path: String) -> Bool {
        guard let attributes = try? fileManager.attributesOfItem(atPath: path) else {
            return false // Failed to get file attributes
        }
        
        guard let extendedAttributes = attributes[FileAttributeKey(rawValue: "NSFileExtendedAttributes")] as? [String: AnyObject] else {
            return false // Failed to get extended attributes
        }
        
        if !extendedAttributes.keys.contains("com.apple.metadata:kMDItemIsScreenCapture") {
            return false // File is not a screenshot
        }
        
        guard let creationDate = attributes[.creationDate] as? NSDate else {
            return false // Failed to get creation date
        }
        
        if creationDate.timeIntervalSinceNow < -5 {
            return false // File is more than 5 seconds old - probably not a new screenshot
        }
        
        return true
    }
    
    func handleEvent(withPath path: String) {
        if recentScreenshotExists(atPath: path) {
            eventHandler(URL(fileURLWithPath: path))
        }
    }
    
    var screenshotDirectoryURL: URL? {
        // Check for custom screenshot location chosen by user
        if let domain = UserDefaults.standard.persistentDomain(forName: "com.apple.screencapture"),
            let path = (domain["location"] as? NSString)?.standardizingPath {
            
            // Check that the chosen directory exists, otherwise screencapture will not use it
            var isDir = ObjCBool(false)
            if fileManager.fileExists(atPath: path, isDirectory: &isDir) && isDir {
                return URL(fileURLWithPath: path)
            }
        }
        
        // If a custom location is not defined (or invalid) return the default screenshot location (~/Desktop)
        return fileManager.urlsForDirectory(.desktopDirectory, inDomains: .userDomainMask).first
    }
}
