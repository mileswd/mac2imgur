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

extension NSMenu {
    
    /// Adds a menu item with the specified options.
    func addItem(withTitle title: String,
                 action: Selector? = nil,
                 target: AnyObject? = nil,
                 representedObject: AnyObject? = nil,
                 state: Int = NSOffState,
                 submenu: NSMenu? = nil) {
        
        let menuItem = NSMenuItem()
        menuItem.title = title
        menuItem.action = action
        menuItem.target = target
        menuItem.representedObject = representedObject
        menuItem.state = state
        menuItem.submenu = submenu
        addItem(menuItem)
    }
    
    /// Creates a section title, which is a title in system small font size
    /// surrounded by two separator items.
    func addItem(withSectionTitle title: String) {
        addItem(.separator())
        
        let menuItem = NSMenuItem()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        menuItem.attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: NSFont.systemFont(
                    ofSize: NSFont.smallSystemFontSize()),
                NSParagraphStyleAttributeName: paragraphStyle
            ])
        
        addItem(menuItem)
        
        addItem(.separator())
    }
    
}
