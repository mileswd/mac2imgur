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
    let imageURL: NSURL
    let isScreenshot: Bool
    var imageData: NSData
    var initiationHandler: ((upload: ImgurUpload) -> Void)?
    var completionHandler: ((upload: ImgurUpload) -> Void)?
    
    var error: String?
    var link: String?
    var successful: Bool {
        return link != nil
    }
    
    init(imagePath: String, isScreenshot: Bool) {
        self.imagePath = imagePath
        self.imageURL = NSURL(fileURLWithPath: imagePath)!
        self.imageData = NSData(contentsOfURL: imageURL, options: nil, error: nil)!
        self.isScreenshot = isScreenshot
    }
    
    func resizeImage(scaleFactor: CGFloat) {
        if let image = NSImage(data: imageData) {
            let resizedBounds = NSRect(x: 0, y: 0, width: round(image.size.width * scaleFactor), height: round(image.size.height * scaleFactor))
            
            // Only resize the image if a change in size will occur
            if !NSEqualSizes(resizedBounds.size, image.size) {
                let resizedImage = NSImage(size: resizedBounds.size)
                let imageRep = image.bestRepresentationForRect(resizedBounds, context: nil, hints: nil)!
                
                resizedImage.lockFocus()
                imageRep.drawInRect(resizedBounds)
                resizedImage.unlockFocus()
                
                // Use a PNG representation of the resized image
                imageData = NSBitmapImageRep(data: resizedImage.TIFFRepresentation!)!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])!
            }
        } else {
            NSLog("An error occurred while attempting to resize %@", imagePath)
        }
    }
}