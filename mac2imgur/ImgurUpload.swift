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
    var imageExtension: String
    var initiationHandler: ((upload: ImgurUpload) -> Void)?
    var completionHandler: ((upload: ImgurUpload) -> Void)?
    
    var error: String?
    var link: String?
    var successful: Bool {
        return link != nil
    }
    
    init(imagePath: String, isScreenshot: Bool) {
        self.imagePath = imagePath
        self.imageURL = NSURL(fileURLWithPath: imagePath)
        self.imageData = NSData(contentsOfURL: imageURL)!
        self.isScreenshot = isScreenshot
        self.imageExtension = imagePath.pathExtension
    }
    
    func downscaleRetinaImage() {
        if let image = NSImage(data: imageData) {
            // Check if image is "retina"
            if Int(image.size.width) < NSBitmapImageRep(data: image.TIFFRepresentation!)!.pixelsWide {
                let resizedImageRep = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(image.size.width),
                    pixelsHigh: Int(image.size.height),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: NSCalibratedRGBColorSpace,
                    bytesPerRow: 0,
                    bitsPerPixel: 0)!
                
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: resizedImageRep))
                image.drawInRect(NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                NSGraphicsContext.restoreGraphicsState()
                
                // Use a PNG representation of the resized image
                imageData = resizedImageRep.representationUsingType(.NSPNGFileType, properties: [:])!
                imageExtension = "png"
            }
        } else {
            NSLog("An error occurred while attempting to resize %@", imagePath)
        }
    }
}