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

// Refined version of http://stackoverflow.com/a/27442962
class LaunchServicesHelper {
    
    let applicationURL = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)
    
    var applicationIsInStartUpItems: Bool {
        return itemReferencesInLoginItems.existingItem != nil
    }
    
    var itemReferencesInLoginItems: (existingItem: LSSharedFileListItem?, lastItem: LSSharedFileListItem?) {
        let itemURL = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        let loginItemsList = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue()
        // Can't cast directly from CFArray to Swift Array, so the CFArray needs to be bridged to a NSArray first
        let loginItemsListSnapshot: NSArray = LSSharedFileListCopySnapshot(loginItemsList, nil).takeRetainedValue()
        if let loginItems = loginItemsListSnapshot as? [LSSharedFileListItem] {
            for loginItem in loginItems {
                if LSSharedFileListItemResolve(loginItem, 0, itemURL, nil) == noErr {
                    if let URL = itemURL.memory?.takeRetainedValue() {
                        // Check whether the item is for this application
                        if URL == applicationURL {
                            return (loginItem, loginItems.last)
                        }
                    }
                }
            }
            // The application was not found in the startup list
            return (nil, loginItems.last ?? kLSSharedFileListItemBeforeFirst.takeRetainedValue())
        }
        return (nil, nil)
    }
    
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems
        let loginItemsList = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue()
        if let existingItem = itemReferences.existingItem {
            // Remove application from login items
            LSSharedFileListItemRemove(loginItemsList, existingItem)
        } else {
            // Add application to login items
            LSSharedFileListInsertItemURL(loginItemsList, itemReferences.lastItem, nil, nil, applicationURL, nil, nil)
        }
    }
}