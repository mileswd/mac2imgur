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
import EMCLoginItem

class PreferencesMenuController: MenuController {
    
    let loginItem = EMCLoginItem()
    
    // MARK: MenuController
    
    override var menuTitle: String {
        return "Preferences"
    }
    
    override var shouldRebuildMenu: Bool {
        return true
    }
    
    override func buildMenu() {
        super.buildMenu()
        
        for category in Preference.Category.allValues {
            menu.addItem(withSectionTitle: category.name)
            
            // Add launch at login option to the top of the general category
            if category == .general, let loginItem = loginItem {
                menu.addItem(withTitle: "Launch at Login",
                             action: #selector(toggleLaunchAtLogin),
                             target: self,
                             state: loginItem.isLoginItem() ? NSOnState : NSOffState)
            }
            
            for preference in Preference.allValues
                where preference.category == category {
                    
                    // Hide resize screenshots preference if the device does
                    // not have any Retina displays
                    if preference == .resizeScreenshots && !hasRetinaDisplay {
                        continue
                    }
                    
                    let menuItem = NSMenuItem()
                    menuItem.title = preference.description
                    menuItem.bind("value",
                                  to: UserDefaults.standard,
                                  withKeyPath: preference.rawValue,
                                  options: nil)
                    menu.addItem(menuItem)
            }
        }
    }
    
    // MARK: General
    
    var hasRetinaDisplay: Bool {
        if let screens = NSScreen.screens() {
            for screen in screens where screen.backingScaleFactor > 1 {
                return true
            }
        }
        return false
    }
    
    func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        guard let loginItem = loginItem else {
            return
        }
        
        if loginItem.isLoginItem() {
            loginItem.remove()
        } else {
            loginItem.add()
        }
    }
    
}
