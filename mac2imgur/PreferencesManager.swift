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

enum PreferencesConstant: String {
    case refreshToken = "RefreshToken", username = "ImgurUsername", deleteScreenshotAfterUpload = "DeleteScreenshotAfterUpload"
}

class PreferencesManager {
    
    var userDefaults: NSUserDefaults
    
    init() {
        userDefaults = NSUserDefaults.standardUserDefaults()
    }
    
    func hasKey(key: String) -> Bool {
        return userDefaults.objectForKey(key) != nil
    }
    
    func getString(key: String, def: String?) -> String? {
        if hasKey(key) {
            return (userDefaults.objectForKey(key) as String)
        } else {
            return def
        }
    }
    
    func getBool(key: String, def: Bool) -> Bool {
        if hasKey(key) {
            return userDefaults.boolForKey(key)
        } else {
            return def
        }
    }
    
    func setString(key: String, value: String) {
        userDefaults.setValue(value, forKey: key)
    }
    
    func setBool(key: String, value: Bool) {
        userDefaults.setBool(value, forKey: key)
    }
    
    func deleteKey(key: String) {
        userDefaults.removeObjectForKey(key)
    }
}