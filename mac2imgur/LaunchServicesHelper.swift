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
    
    let applicationURL = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)!
    
    var applicationIsInStartUpItems: Bool {
        return itemReferencesInLoginItems.existingReference != nil
    }
    
    var itemReferencesInLoginItems: (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        var itemURL = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef? {
            let loginItems = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
            let lastItemRef = loginItems.lastObject as! LSSharedFileListItemRef?
            for loginItem in loginItems {
                let currentItemRef = loginItem as! LSSharedFileListItemRef
                if LSSharedFileListItemResolve(currentItemRef, 0, itemURL, nil) == noErr {
                    if let URLRef = itemURL.memory?.takeRetainedValue() as? NSURL {
                        if URLRef.isEqual(applicationURL) {
                            return (currentItemRef, lastItemRef)
                        }
                    }
                }
            }
            // The application was not found in the startup list
            return (nil, lastItemRef ?? kLSSharedFileListItemBeforeFirst.takeRetainedValue())
        }
        return (nil, nil)
    }
    
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems
        if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef? {
            if let existingRef = itemReferences.existingReference {
                // Remove application from login items
                LSSharedFileListItemRemove(loginItemsRef, existingRef)
            } else {
                // Add application to login items
                LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, applicationURL, nil, nil)
            }
        }
    }
}