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

class ImgurAlbumMenuController: MenuController {
    
    // MARK: General
    
    var albums = [IMGAlbum]()
    var albumsFetched = false
    
    /// Retrieves the available albums from the Imgur API
    func updateAlbums() {
        guard let username = IMGSession.sharedInstance().user?.username else {
            return // Unable to get current username
        }
        
        IMGAccountRequest.accountAlbums(
            withUser: username,
            withPage: 0,
            success: { (albums) in
                
                if let albums = albums as? [IMGAlbum] {
                    self.albums = albums
                    self.albumsFetched = true
                    self.rebuildMenu()
                }
                
            }, failure: nil)
    }
    
    func selectAlbum(_ sender: NSMenuItem) {
        if let album = sender.representedObject as? IMGAlbum {
            if ImgurClient.shared.uploadAlbumID == album.albumID {
                ImgurClient.shared.uploadAlbumID = nil
            } else {
                ImgurClient.shared.uploadAlbumID = album.albumID
            }
        }
    }
    
    // MARK: MenuController
    
    override var menuTitle: String {
        return "Upload to Album"
    }
    
    override var shouldRebuildMenu: Bool {
        return true
    }
    
    override func buildMenu() {
        super.buildMenu()
        
        if !albumsFetched {
            updateAlbums()
        }
        
        if albumsFetched && albums.isEmpty {
            menu.addItem(withTitle: "No Albums Available")
        } else {
            for album in albums {
                menu.addItem(withTitle: album.title,
                             action: #selector(selectAlbum(_:)),
                             target: self,
                             representedObject: album,
                             state: ImgurClient.shared.uploadAlbumID
                                == album.albumID ? NSOnState : NSOffState)
            }
        }
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: albumsFetched ? "Reload Albums" : "Loading Albums…",
                     action: albumsFetched ? #selector(updateAlbums) : nil,
                     target: self)
    }
    
    
    
}
