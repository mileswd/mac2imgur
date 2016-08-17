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
import Crashlytics

class ImgurClient: NSObject, IMGSessionDelegate {
    
    static let shared = ImgurClient()
    
    var externalWebViewCompletionHandler: (() -> Void)?
    
    // MARK: Defaults keys
    
    let refreshTokenKey = "RefreshToken"
    let imgurAlbumKey = "ImgurAlbum"
    
    // MARK: Imgur tokens
    
    let clientID = "5867856c9027819"
    let clientSecret = "7c2a63097cbb0f10f260291aab497be458388a64"
    
    // MARK: General
    
    var uploadAlbumID: String? {
        get {
            return UserDefaults.standard.string(forKey: imgurAlbumKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: imgurAlbumKey)
        }
    }
    
    /// Prepare ImgurClient for use.
    func setup() {
        if let refreshToken = UserDefaults.standard.string(forKey: refreshTokenKey) {
            configure(asAnonymous: false)
            
            IMGSession.sharedInstance()
                .authenticate(withRefreshToken: refreshToken)
        } else {
            configure(asAnonymous: true)
        }
    }
    
    func handleError(_ error: Error?, title: String) {
        if let error = error {
            Crashlytics.sharedInstance().recordError(error)
            NSLog("%@: %@", title, error as NSError)
        }
        
        let description = error?.localizedDescription ?? "An unknown error occured"
        
        UserNotificationController.shared
            .displayNotification(withTitle: title, informativeText: description)
    }
    
    /// Configures the `IMGSession.sharedInstance()`
    /// - parameter anonymous: If the session should be configured for anonymous
    /// API access, or alternatively authenticated.
    func configure(asAnonymous anonymous: Bool) {
        if anonymous {
            IMGSession.anonymousSession(
                withClientID: clientID,
                with: self)
        } else {
            IMGSession.authenticatedSession(
                withClientID: clientID,
                secret: clientSecret,
                authType: .codeAuth,
                with: self)
            
            // Disable notification update requests
            IMGSession.sharedInstance().notificationRefreshPeriod = 0
        }
    }
    
    func authenticate() {
        configure(asAnonymous: false)
        IMGSession.sharedInstance().authenticate()
    }
    
    func deauthenticate() {
        // Clear stored refresh token
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: imgurAlbumKey)
        
        configure(asAnonymous: true)
    }
    
    /// Requests manual upload confirmation from the user if required,
    /// otherwise returns `true`
    /// - parameter upload: The upload for which confirmation is required
    func hasUploadConfirmation(forImageNamed imageName: String, imageData: Data) -> Bool {
        // Manual upload confirmation may not be required
        if !Preference.requiresUploadConfirmation.value {
            return true
        }
        
        let alert = NSAlert()
        alert.messageText = "Do you want to upload this screenshot?"
        alert.informativeText = "\"\(imageName)\" will be uploaded to imgur.com, where it will be publicly accessible."
        alert.addButton(withTitle: "Upload")
        alert.addButton(withTitle: "Cancel")
        alert.icon = NSImage(data: imageData)
        
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal() == NSAlertFirstButtonReturn
    }
    
    /// Returns a PNG image representation data of the supplied image data,
    /// reduced to non-retina scale
    func downscaleRetinaImageData(_ data: Data) -> Data? {
        guard let image = NSImage(data: data) else {
            NSLog("Resize failed: Unable to create image from image data")
            return nil
        }
        
        guard let imageRep = image.representations.first else {
            NSLog("Resize failed: Unable to get image representation")
            return nil
        }
        
        if image.size.width >= CGFloat(imageRep.pixelsWide) {
            NSLog("Resize skipped: Image is not retina")
            return nil
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
                NSLog("Resize failed: Unable to create bitmap image representation")
                return nil
        }
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: bitmapImageRep))
        image.draw(in: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        NSGraphicsContext.restoreGraphicsState()
        
        // Use a PNG representation of the resized image
        guard let resizedRep = bitmapImageRep.representation(using: .PNG, properties: [:]) else {
            NSLog("Resize failed: Unable to create PNG representation")
            return nil
        }
        
        return resizedRep
    }
    
    // MARK: Imgur Upload
    
    /// Uploads the image at the specified URL.
    /// - parameter imageURL: The URL to the image to be uploaded
    /// - parameter isScreenshot: Whether the image is a screenshot or not,
    /// affects which preferences will be applied to the upload
    func uploadImage(withURL imageURL: URL, isScreenshot: Bool) {
        
        var imageData: Data
        
        do {
            imageData = try Data(contentsOf: imageURL)
        } catch let error {
            uploadFailureHandler(error)
            return
        }
        
        let imageName = imageURL.lastPathComponent
        
        // Screenshot specific preferences
        if isScreenshot {
            
            if Preference.disableScreenshotDetection.value
                || !hasUploadConfirmation(forImageNamed: imageName, imageData: imageData) {
                return // Skip, do not upload
            }
            
            // Downscale retina image if required
            if Preference.resizeScreenshots.value,
                let resizedImageData = downscaleRetinaImageData(imageData) {
                imageData = resizedImageData
            }
            
            // Move the image to trash if required
            if Preference.deleteScreenshotsAfterUpload.value {
                NSWorkspace.shared().recycle([imageURL], completionHandler: nil)
            }
            
        }
        
        uploadImage(withData: imageData,
                    imageTitle: NSString(string: imageName).deletingPathExtension)
    }
    
    /// Uploads the specified image data
    /// - parameter imageData: The image data of which to upload
    /// - parameter imageTitle: The title of the image (defaults to "Untitled")
    func uploadImage(withData imageData: Data, imageTitle: String = "Untitled") {
        
        // Clear clipboard if required
        if Preference.clearClipboard.value {
            NSPasteboard.general().clearContents()
        }
        
        IMGImageRequest.uploadImage(with: imageData,
                                    title: imageTitle,
                                    description: nil,
                                    linkToAlbumWithID: uploadAlbumID,
                                    success: uploadSuccessHandler,
                                    progress: nil,
                                    failure: uploadFailureHandler)
    }
    
    func uploadSuccessHandler(_ image: IMGImage?) {
        guard let image = image,
            let urlString = image.secureURL?.absoluteString else {
                return
        }
        
        ImgurImageStore.shared.addImage(image)
        
        // Copy link to clipboard if required
        if Preference.copyLinkToClipboard.value,
            let urlString = image.secureURL?.absoluteString{
            NSPasteboard.general().clearContents()
            NSPasteboard.general()
                .setString(urlString, forType: NSPasteboardTypeString)
        }
        
        UserNotificationController.shared.displayNotification(
            withTitle: "Imgur Upload Succeeded",
            informativeText: urlString)
    }
    
    func uploadFailureHandler(_ error: Error?) {
        handleError(error, title: "Imgur Upload Failed")
    }
    
    // MARK: IMGSessionDelegate
    
    func imgurRequestFailed(_ error: Error!) {
        handleError(error, title: "Imgur Request Failed")
    }
    
    func imgurSessionRateLimitExceeded() {
        UserNotificationController.shared
            .displayNotification(withTitle: "Imgur Rate Limit Exceeded",
                                 informativeText: "Further Imgur requests may fail")
    }
    
    func imgurSessionNeedsExternalWebview(_ url: URL!, completion: (() -> Void)!) {
        externalWebViewCompletionHandler = completion
        NSWorkspace.shared().open(url)
    }
    
    func imgurSessionUserRefreshed(_ user: IMGAccount!) {
        guard let username = user.username,
            let refreshToken = IMGSession.sharedInstance().refreshToken else {
                return
        }
        
        if UserDefaults.standard.string(forKey: refreshTokenKey) == nil {
            UserNotificationController.shared
                .displayNotification(withTitle: "Authentication Succeeded",
                                     informativeText: "Signed in as \(username)")
        }
        
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
    }
    
    // MARK: External WebView Handler
    
    func handleExternalWebViewEvent(withResponseURL url: URL) {
        guard let query = url.query?.components(separatedBy: "&") else {
            NSLog("Unable to find URL query component: \(url)")
            return
        }
        
        for parameter in query {
            let pair = parameter.components(separatedBy: "=")
            
            if pair.count == 2 && pair[0] == "code" {
                IMGSession.sharedInstance().authenticate(withCode: pair[1])
                externalWebViewCompletionHandler?()
                externalWebViewCompletionHandler = nil
                return
            }
        }
    }
    
}
