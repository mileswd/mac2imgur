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

class ImgurClient {
    
    let apiURL = "https://api.imgur.com"
    
    var uploadQueue = [ImgurUpload]()
    var authenticationInProgress = false
    var tokenExpiryDate: NSDate?
    
    var username: String?
    var refreshToken: String?
    
    init(username: String?, refreshToken: String?) {
        self.username = username
        self.refreshToken = refreshToken
    }
    
    var accessToken: String? {
        didSet {
            // Update token expiry date (imgur access tokens are valid for 1 hour)
            tokenExpiryDate = NSDate(timeIntervalSinceNow: 1 * 60 * 60)
        }
    }
    
    var isAuthenticated: Bool {
        return username != nil && refreshToken != nil
    }
    
    var accessTokenIsValid: Bool {
        if accessToken != nil {
            return tokenExpiryDate!.timeIntervalSinceReferenceDate > NSDate().timeIntervalSinceReferenceDate
        }
        return false
    }
    
    func addToQueue(upload: ImgurUpload) {
        upload.initiationHandler?(upload: upload)
        // If necessary, request a new access token
        if isAuthenticated && !accessTokenIsValid {
            uploadQueue.append(upload)
            if !authenticationInProgress {
                authenticationInProgress = true
                requestAccessToken({ () -> Void in
                    self.authenticationInProgress = false
                    self.processQueue()
                })
            }
        } else {
            attemptUpload(upload)
        }
    }
    
    func processQueue() {
        // Upload all images in queue
        for upload in uploadQueue {
            if accessTokenIsValid {
                attemptUpload(upload)
            } else {
                upload.error = "Unable to authenticate with Imgur"
                upload.completionHandler?(upload: upload)
            }
        }
        // Clear queue
        uploadQueue.removeAll(keepCapacity: false)
    }
    
    func deauthenticate() {
        username = nil
        refreshToken = nil
        accessToken = nil
    }
    
    /**
    Authenticate with the Imgur API
    
    :param: code The authorization code obtained from the Imgur API
    
    :callback: The code to be executed upon a successful authentication attempt
    */
    func authenticate(code: String, callback: (username: String, refreshToken: String) -> Void) {
        let parameters = [
            "client_id": imgurClientId,
            "client_secret": imgurClientSecret,
            "grant_type": "authorization_code",
            "code": code
        ]
        Just.post(
            "\(apiURL)/oauth2/token",
            timeout: 30,
            json: parameters) { (result: HTTPResult!) -> Void in
                self.refreshToken = result.json?.objectForKey("refresh_token") as? String
                self.accessToken = result.json?.objectForKey("access_token") as? String
                self.username = result.json?.objectForKey("account_username") as? String
                if self.username != nil && self.refreshToken != nil {
                    callback(username: self.username!, refreshToken: self.refreshToken!)
                } else {
                    NSLog("An error occurred while attempting to obtain tokens from a pin: \(result.error)\nResponse: \(result.response)\nJSON: \(result.json)")
                }
        }
    }
    
    func requestAccessToken(callback: () -> Void) {
        let parameters = [
            "client_id": imgurClientId,
            "client_secret": imgurClientSecret,
            "grant_type": "refresh_token",
            "refresh_token": self.refreshToken!
        ]
        Just.post(
            "\(apiURL)/oauth2/token",
            timeout: 30,
            json: parameters) { (result: HTTPResult!) -> Void in
                if let accessToken = result.json?.objectForKey("access_token") as? String {
                    self.accessToken = accessToken
                } else {
                    NSLog("An error occurred while attempting to obtain tokens from a pin: \(result.error)\nResponse: \(result.response)\nJSON: \(result.json)")
                }
                callback()
        }
    }
    
    func attemptUpload(upload: ImgurUpload) {
        let headers = [
            "Authorization": isAuthenticated ? "Client-Bearer \(accessToken!)" : "Client-ID \(imgurClientId)"
        ]
        let parameters = [
            "title": upload.imagePath.lastPathComponent.stringByDeletingPathExtension,
            "description": "Uploaded by mac2imgur! (https://mileswd.com/mac2imgur)"
        ]
        let files = [
            "image": HTTPFile.Data("image.\(upload.imageExtension)", upload.imageData, nil)
        ]
        Just.post(
            "\(apiURL)/3/image",
            timeout: 90,
            json: parameters,
            files: files,
            headers: headers) { (result: HTTPResult!) -> Void in
                if let link = result.json?.objectForKey("data")?.objectForKey("link") as? String {
                    // Update link provided by API to HTTPS if necessary
                    upload.link = link.stringByReplacingOccurrencesOfString("http://", withString: "https://")
                } else {
                    if let error = result.json?.objectForKey("data")?.objectForKey("error") as? String {
                        upload.error = "Imgur responded with the following error: \"\(error)\""
                    } else {
                        upload.error = result.error?.localizedDescription
                    }
                    NSLog("An error occurred while attempting to upload an image: \(result.error)\nResponse: \(result.response)\nJSON: \(result.json)")
                }
                upload.completionHandler?(upload: upload)
        }
    }
}