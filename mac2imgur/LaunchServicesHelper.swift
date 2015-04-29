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

class LaunchServicesHelper {

    static private let applicationURL = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)!

    static private var loginItems: LSSharedFileList? {
        if let loginItems = LSSharedFileListCreate(CFAllocatorGetDefault().takeUnretainedValue(), kLSSharedFileListSessionLoginItems.takeUnretainedValue(), nil) {
            return loginItems.takeRetainedValue()
        }
        return nil
    }

    static private var loginItem: LSSharedFileListItem? {
        for item in LSSharedFileListCopySnapshot(loginItems, nil).takeRetainedValue() as NSArray {
            if (LSSharedFileListItemCopyResolvedURL(item as! LSSharedFileListItem, 0, nil).takeRetainedValue() as NSURL).isEqual(applicationURL) {
                return (item as! LSSharedFileListItem)
            }
        }
        return nil
    }

    static var shouldLaunchAtLogin: Bool {
        set {
            if shouldLaunchAtLogin && !newValue {
                LSSharedFileListItemRemove(loginItems, loginItem!)
            } else if !shouldLaunchAtLogin && newValue {
                LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst.takeUnretainedValue(), nil, nil, applicationURL as CFURL, nil, nil)
            }
        }
        get {
            return loginItem != nil
        }
    }
}