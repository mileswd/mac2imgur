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
    
    let eventHandler: (URL) -> Void
    var eventStream: FSEventStreamRef?
    var handledURLs: [URL]
    
    init(eventHandler: @escaping (URL) -> Void) {
        self.eventHandler = eventHandler
        self.handledURLs = []
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        guard let path = screenshotDirectoryURL?.path else {
            NSLog("Failed to get screenshot directory")
            return
        }
        
        let streamCallback: FSEventStreamCallback = {
            (streamRef: ConstFSEventStreamRef,
            clientCallBackInfo: UnsafeMutableRawPointer?,
            numEvents: Int,
            eventPaths: UnsafeMutableRawPointer,
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
                screenshotMonitor.handleEvent(withURL: URL(fileURLWithPath: $0))
            }
        }
        
        var streamContext = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passRetained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil)
        
        guard let eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            streamCallback,
            &streamContext,
            [path] as CFArray,
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
    
    func handleEvent(withURL url: URL) {
        if !handledURLs.contains(url) && recentScreenshotExists(at: url) {
            handledURLs.append(url)
            eventHandler(url)
        }
    }
    
    func recentScreenshotExists(at url: URL) -> Bool {
        
        if url.lastPathComponent.hasPrefix(".") {
            return false // File is hidden
        }
        
        guard let attributes = try? FileManager.default
            .attributesOfItem(atPath: url.path) else {
                return false // Failed to get file attributes
        }
        
        let extendedAttributesKey =
            FileAttributeKey(rawValue: "NSFileExtendedAttributes")
        
        guard let extendedAttributes = attributes[extendedAttributesKey]
            as? [String: Any] else {
                return false // Failed to get extended attributes
        }
        
        if !extendedAttributes.keys.contains("com.apple.metadata:kMDItemIsScreenCapture") {
            return false // File is not a screenshot
        }
        
        guard let creationDate = attributes[.creationDate] as? Date else {
            return false // Failed to get creation date
        }
        
        if creationDate.timeIntervalSinceNow < -5 {
            return false // File is more than 5 seconds old - probably not a new screenshot
        }
        
        return true
    }
    
    var screenshotDirectoryURL: URL? {
        // Check for custom screenshot location chosen by user
        if let domain = UserDefaults.standard.persistentDomain(forName: "com.apple.screencapture"),
            let path = (domain["location"] as? NSString)?.standardizingPath {
            
            // Check that the chosen directory exists, otherwise screencapture will not use it
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue {
                return URL(fileURLWithPath: path)
            }
        }
        
        // If a custom location is not defined (or invalid) return the default screenshot location (~/Desktop)
        return FileManager.default.urls(for: .desktopDirectory,
                                        in: .userDomainMask).first
    }
}
