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
import ImgurSession

class ImgurMenuController: MenuController {
    
    let imgurAlbumMenuController = ImgurAlbumMenuController()
    
    // MARK: MenuController
    
    override var menuTitle: String {
        return "Imgur"
    }
    
    override var shouldRebuildMenu: Bool {
        return true
    }
    
    override func buildMenu() {
        super.buildMenu()
        
        var accountStatusItemTitle: String
        
        if IMGSession.sharedInstance().isAnonymous {
            accountStatusItemTitle = "Sign In…"
        } else {
            accountStatusItemTitle = "Sign Out"
            if let username = IMGSession.sharedInstance().user?.username {
                accountStatusItemTitle += " (\(username))"
            }
        }
        
        menu.addItem(withTitle: accountStatusItemTitle,
                     action: #selector(toggleAuthentication),
                     target: self)
        
        if !IMGSession.sharedInstance().isAnonymous {
        
            menu.addItem(.separator())
            
            menu.addItem(withTitle: imgurAlbumMenuController.menuTitle,
                         submenu: imgurAlbumMenuController.menu)
            
            menu.addItem(withTitle: "View Images",
                         action: #selector(viewImages),
                         target: self)
        }
    }
    
    // MARK: General
    
    func toggleAuthentication() {
        if IMGSession.sharedInstance().isAnonymous {
            ImgurClient.shared.authenticate()
        } else {
            ImgurClient.shared.deauthenticate()
        }
    }
    
    /// Opens the online uploaded images page for the current user.
    func viewImages() {
        if let username = IMGSession.sharedInstance().user?.username,
            let url = URL(string: "https://\(username).imgur.com/all/") {
            NSWorkspace.shared().open(url)
        }
    }
}
