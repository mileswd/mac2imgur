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
    
    let isScreenshot: Bool
    let imageURL: NSURL
    let imageName: String
    var imageData: NSData
    
    var completionHandler: (ImgurUpload -> Void)?
    var error: String?
    var link: String?
    
    init(imageURL: NSURL, isScreenshot: Bool) {
        self.imageURL = imageURL
        self.imageName = imageURL.lastPathComponent ?? "Unnamed"
        self.imageData = NSData(contentsOfURL: imageURL)!
        self.isScreenshot = isScreenshot
    }
    
    func downscaleRetinaImage() {
        guard let image = NSImage(data: imageData) else {
            NSLog("Resize failed: Unable to create image from image data")
            return
        }
        
        guard let imageRep = image.representations.first else {
            NSLog("Resize failed: Unable to get image representation")
            return
        }
        
        if image.size.width >= CGFloat(imageRep.pixelsWide) {
            NSLog("Resize skipped: Image is not retina")
            return
        }
        
        guard let bitmapImageRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(image.size.width),
            pixelsHigh: Int(image.size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSCalibratedRGBColorSpace,
            bytesPerRow: 0,
            bitsPerPixel: 0) else {
                NSLog("Resize failed: Unable to create bitmap image representation from image data")
                return
        }
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: bitmapImageRep))
        image.drawInRect(NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        NSGraphicsContext.restoreGraphicsState()
        
        // Use a PNG representation of the resized image
        if let resizedRep = bitmapImageRep.representationUsingType(.NSPNGFileType, properties: [:]) {
            imageData = resizedRep
        } else {
            NSLog("Resize failed: Unable to create PNG representation")
        }
    }
}