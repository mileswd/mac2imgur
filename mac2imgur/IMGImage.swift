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
import ImgurSession

extension IMGImage {
    
    /// Returns the URL using the `https` scheme.
    /// - parameter url: The URL to use (must have the scheme `http`)
    func secureProtocol(usingURL url: URL) -> URL? {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if components?.scheme == "http" {
            components?.scheme = "https"
        }
        
        return components?.url
    }
    
    /// Returns a `https` version of the `url` property.
    var secureURL: URL? {
        return secureProtocol(usingURL: url)
    }
    
    /// Returns a `https` version of the `url(with:)` method.
    func secureURL(with size: IMGSize) -> URL? {
        return secureProtocol(usingURL: url(with: size))
    }
    
    /// Copies the `secureURL` to the general pasteboard.
    func copyURL() {
        if let urlString = secureURL?.absoluteString {
            NSPasteboard.general().clearContents()
            NSPasteboard.general().setString(urlString, forType: NSStringPboardType)
        }
    }
    
    /// Opens the `secureURL` in the browser.
    func openURL() {
        if let secureURL = secureURL {
            NSWorkspace.shared().open(secureURL)
        }
    }
    
    /// Opens the image editing page on imgur.com.
    func openEditURL() {
        if let deletehash = deletehash,
            let url = URL(string: "https://imgur.com/edit?deletehash=\(deletehash)") {
            NSWorkspace.shared().open(url)
        }
    }
    
    /// Opens the image deletion page on imgur.com.
    func openDeleteURL() {
        if let deletehash = deletehash,
            let url = URL(string: "https://imgur.com/delete/\(deletehash)") {
            NSWorkspace.shared().open(url)
        }
    }
}
