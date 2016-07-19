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
import AFNetworking

class StatusItemController: NSObject, NSWindowDelegate, NSDraggingDestination {
    
    let statusItem: NSStatusItem
    let statusItemMenuController: StatusItemMenuController
    
    var currentOperationCount = 0
    
    override init() {
        statusItem = NSStatusBar.system().statusItem(
            withLength: NSVariableStatusItemLength)
        
        statusItemMenuController = StatusItemMenuController()
        
        super.init()
        
        statusItem.menu = statusItemMenuController.menu
        updateStatusItemImage()
        
        // Enable drag and drop upload if OS X >= 10.10
        if #available(OSX 10.10, *) {
            statusItem.button?.window?.delegate = self
            statusItem.button?.window?
                .registerForDraggedTypes([NSFilenamesPboardType, NSTIFFPboardType])
        }
        
        NotificationCenter.default.addObserver(forName: .AFNetworkingTaskDidResume,
                                               object: nil,
                                               queue: nil,
                                               using: notificationHandler)
        
        NotificationCenter.default.addObserver(forName: .AFNetworkingTaskDidComplete,
                                               object: nil,
                                               queue: nil,
                                               using: notificationHandler)
    }
    
    func notificationHandler(notification: Notification) {
        if notification.name == .AFNetworkingTaskDidResume {
            currentOperationCount += 1
        } else if notification.name == .AFNetworkingTaskDidComplete {
            currentOperationCount -= 1
        }
        updateStatusItemImage()
    }
    
    func updateStatusItemImage() {
        statusItem.image = currentOperationCount > 0
            ? #imageLiteral(resourceName: "StatusActive") : #imageLiteral(resourceName: "StatusInactive")
    }
    
    deinit {
        NSStatusBar.system().removeStatusItem(statusItem)
    }
    
    // MARK: NSDraggingDestination
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let data = sender.draggingPasteboard().data(forType: NSTIFFPboardType) {
            ImgurClient.shared.uploadImage(withData: data)
            return true
        } else if let paths = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? [String] {
            for path in paths {
                ImgurClient.shared.uploadImage(withURL: URL(fileURLWithPath: path),
                                               isScreenshot: false)
            }
            return true
        }
        return false
    }
    
}
