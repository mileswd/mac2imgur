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

class ImgurAuthWindowController: NSWindowController {
    
    var imgurClient: ImgurClient!
    var prefs: PreferencesManager!
    var callback: (() -> ())!
    
    @IBOutlet weak var signInButton: NSButton!
    @IBOutlet weak var pinCodeField: NSTextField!
    @IBOutlet weak var saveButton: NSButton!

    @IBAction func signInButtonClick(sender: AnyObject) {
        imgurClient.openBrowserForAuth()
    }
    
    @IBAction func onSaveButtonClick(sender: AnyObject) {
        if pinCodeField.stringValue != "" {
            imgurClient.getTokenFromPin(pinCodeField.stringValue, callback: {
                dispatch_async(dispatch_get_main_queue()) {
                    if let authWindow = self.window {
                        authWindow.close()
                    }
                }
                self.callback()
            })
        }
    }
}