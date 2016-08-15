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

class ImgurImageStore {
    
    static let shared = ImgurImageStore()
    
    let imagesKey = "Images"
    
    /// Returns an array of all the images store in UserDefaults.
    var images: [IMGImage] {
        get {
            guard let data = UserDefaults.standard.object(forKey: imagesKey) as? Data else {
                return []
            }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [IMGImage] ?? []
        }
        set {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: newValue),
                                      forKey: imagesKey)
        }
    }
    
    /// Stores the specified image.
    /// - parameter image: The image to store
    func addImage(_ image: IMGImage) {
        images.insert(image, at: 0)
    }
    
    /// Removes all stored images.
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: imagesKey)
    }
    
    func addObserver(_ observer: NSObject) {
        UserDefaults.standard.addObserver(observer,
                                          forKeyPath: imagesKey,
                                          options: [],
                                          context: nil)
    }
    
    // MARK: Preview Images
    
    var cachedImages = [URL: NSImage]()
    
    /// Attempts to retrieve a preview image of the specified image.
    /// - parameter image: The image for which to request a preview image.
    /// - parameter completionHandler: The completion handler to call if the
    /// image has been retrieved successfully.
    func requestPreviewImage(forImage image: IMGImage, completionHandler: @escaping (NSImage) -> Void) {
        guard let url = image.secureURL(with: .smallSquareSize) else {
            return
        }
        
        if let cachedImage = cachedImages[url] {
            completionHandler(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
            if let data = data, let image = NSImage(data: data) {
                DispatchQueue.main.async(execute: {
                    completionHandler(image)
                })
            }
        }).resume()
    }

}
