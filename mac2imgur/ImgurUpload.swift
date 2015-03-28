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

class ImgurUpload {
    
    let imagePath: String
    let imageUrl: NSURL
    let isScreenshot: Bool
    let callback: (upload: ImgurUpload) -> ()
    
    var error: String?
    var link: String?
    var successful: Bool {
        return link != nil
    }
    
    init(imagePath: String, isScreenshot: Bool, callback: (upload: ImgurUpload) -> ()) {
        self.imagePath = imagePath
        self.imageUrl = NSURL(fileURLWithPath: imagePath)!
        self.isScreenshot = isScreenshot
        self.callback = callback
    }
}