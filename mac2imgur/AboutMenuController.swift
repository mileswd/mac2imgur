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
import Sparkle

class AboutMenuController: MenuController {
    
    override var menuTitle: String {
        return "About"
    }
    
    override func buildMenu() {
        super.buildMenu()
        
        menu.addItem(withTitle: "Project Website",
                     action: #selector(projectWebsite),
                     target: self)
        
        menu.addItem(withTitle: "Acknowledgements",
                     action: #selector(showAcknowledgements),
                     target: self)
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Check for Updates…",
                     action: #selector(SUUpdater.checkForUpdates(_:)),
                     target: SUUpdater.shared())
        
        if let formattedVersion = self.formattedVersion {
            menu.addItem(withTitle: formattedVersion)
        }
    }
    
    // MARK: General
    
    /// Returns the version of the application in the format:
    /// `Version <CFBundleShortVersionString> (<CFBundleVersion>)`.
    var formattedVersion: String? {
        guard let info = Bundle.main.infoDictionary,
            let version = info["CFBundleShortVersionString"] as? String,
            let build = info["CFBundleVersion"] as? String else {
                return nil
        }
        return "Version \(version) (\(build))"
    }
    
    /// Opens the project website in the default browser.
    func projectWebsite() {
        if let url = URL(string: "https://github.com/mileswd/mac2imgur") {
            NSWorkspace.shared().open(url)
        }
    }
    
    /// Opens the bundle acknowledgements file in TextEdit.
    func showAcknowledgements() {
        if let path = Bundle.main.path(forResource: "Pods-mac2imgur-acknowledgements", ofType: "markdown") {
            NSWorkspace.shared().openFile(path, withApplication: "TextEdit")
        }
    }
    
}
