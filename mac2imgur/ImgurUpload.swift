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

class ImgurUpload {
    
    let imagePath: String
    let imageUrl: NSURL
    let isScreenshot: Bool
    let callback: (upload: ImgurUpload) -> ()
    var imageData: NSData
    
    var error: String?
    var link: String?
    var successful: Bool {
        return link != nil
    }
    
    init(imagePath: String, isScreenshot: Bool, callback: (upload: ImgurUpload) -> ()) {
        self.imagePath = imagePath
        self.imageUrl = NSURL(fileURLWithPath: imagePath)!
        self.imageData = NSData(contentsOfURL: imageUrl, options: nil, error: nil)!
        self.isScreenshot = isScreenshot
        self.callback = callback
    }
    
    func resizeImage() {
        let retinaScaleDownFactor = 1 / NSScreen.mainScreen()!.backingScaleFactor
        let image = NSImage(data: imageData)!
        let resizedBounds = NSRect(x: 0, y: 0, width: Int(round(image.size.width * retinaScaleDownFactor)), height: Int(round(image.size.height * retinaScaleDownFactor)))
        let resizedImage = NSImage(size: resizedBounds.size)
        let imageRep = image.bestRepresentationForRect(resizedBounds, context: nil, hints: nil)
        
        resizedImage.lockFocus()
        image.drawInRect(resizedBounds)
        resizedImage.unlockFocus()
        
        imageData = resizedImage.TIFFRepresentation!
    }
}