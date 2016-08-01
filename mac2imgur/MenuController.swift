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

class MenuController: NSObject, NSMenuDelegate {
    
    let menu: NSMenu
    
    override init() {
        self.menu = NSMenu()
        
        super.init()
        
        menu.delegate = self
    }
    
    /// Creates the menu from scratch.
    func buildMenu() {
        menu.removeAllItems()
        
        // Menu creation logic
    }
    
    /// Whether the menu should be rebuilt before it is displayed.
    var shouldRebuildMenu: Bool {
        return false
    }
    
    /// The title of the menu.
    var menuTitle: String {
        return ""
    }
    
    /// Rebuilds the menu, even if it is currently open.
    func rebuildMenu() {
        let timer = Timer(timeInterval: 0,
                          target: self,
                          selector: #selector(buildMenu),
                          userInfo: nil,
                          repeats: false)
        
        RunLoop.current.add(timer, forMode: .eventTrackingRunLoopMode)
    }
    
    // MARK: NSMenuDelegate
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        if shouldRebuildMenu || menu.numberOfItems == 0 {
            buildMenu()
        }
    }
    
}
