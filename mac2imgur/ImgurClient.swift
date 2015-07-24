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
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var uploadQueue = [ImgurUpload]()
    var authenticationInProgress = false
    var tokenExpiryDate: NSDate?
    
    var username: String? {
        get {
            return defaults.stringForKey(kImgurUsername)
        }
        set {
            defaults.setObject(newValue, forKey: kImgurUsername)
        }
    }
    
    var refreshToken: String? {
        get {
            return defaults.stringForKey(kRefreshToken)
        }
        set {
            defaults.setObject(newValue, forKey: kRefreshToken)
        }
    }
    
    var accessToken: String? {
        didSet {
            // Update token expiry date (Imgur access tokens are valid for 1 hour)
            tokenExpiryDate = NSDate(timeIntervalSinceNow: 1 * 60 * 60)
        }
    }
    
    var isAuthenticated: Bool {
        return username != nil && refreshToken != nil
    }
    
    var accessTokenIsValid: Bool {
        if let expiry = tokenExpiryDate {
            return expiry.timeIntervalSinceNow > 0 && accessToken != nil
        }
        return false
    }
    
    func deauthenticate() {
        defaults.removeObjectForKey(kImgurUsername)
        defaults.removeObjectForKey(kRefreshToken)
        accessToken = nil
    }
    
    func addToQueue(upload: ImgurUpload) {
        if isAuthenticated && !accessTokenIsValid {
            
            // Queue the upload if we need an access token
            uploadQueue.append(upload)
            
            // Request the access token if it hasn't already been requested
            if !authenticationInProgress {
                
                authenticationInProgress = true
                
                requestAccessToken({ (authError: String?) -> Void in
                    if let error = authError {
                        upload.error = error
                        upload.completionHandler?(upload)
                    } else {
                        // Upload all images in the queue
                        while self.uploadQueue.count != 0 {
                            self.attemptUpload(self.uploadQueue[0])
                            self.uploadQueue.removeAtIndex(0)
                        }
                    }
                    
                    self.authenticationInProgress = false
                })
            }
        } else {
            // We don't need any access tokens, just upload the image
            attemptUpload(upload)
        }
    }
    
    func readableErrorFromResult(result: HTTPResult) -> String {
        NSLog("A HTTP request error occurred: \(result.error)\n\n\(result.json)\n\n\(result.response)")
        if let error = result.json?.objectForKey("data")?.objectForKey("error") as? String {
            return error
        } else if let error = result.error?.localizedDescription {
            return error
        } else {
            return "An unknown error occurred"
        }
    }
    
    func requestRefreshToken(code: String, callback: (String?) -> Void) {
        let parameters = [
            "client_id": imgurClientId,
            "client_secret": imgurClientSecret,
            "grant_type": "authorization_code",
            "code": code
        ]
        Just.post("\(apiURL)/oauth2/token", timeout: 30, json: parameters) { (result: HTTPResult!) -> Void in
            if let username = result.json?["account_username"] as? String,
                let refreshToken = result.json?["refresh_token"] as? String,
                let accessToken = result.json?["access_token"] as? String {
                    self.username = username
                    self.refreshToken = refreshToken
                    self.accessToken = accessToken
                    callback(nil)
            } else {
                callback(self.readableErrorFromResult(result))
            }
        }
    }
    
    func requestAccessToken(callback: (String?) -> Void) {
        let parameters = [
            "client_id": imgurClientId,
            "client_secret": imgurClientSecret,
            "grant_type": "refresh_token",
            "refresh_token": self.refreshToken!
        ]
        Just.post("\(apiURL)/oauth2/token", timeout: 30, json: parameters) { (result: HTTPResult!) -> Void in
            if let accessToken = result.json?["access_token"] as? String,
                let refreshToken = result.json?["refresh_token"] as? String {
                    self.accessToken = accessToken
                    self.refreshToken = refreshToken
                    callback(nil)
            } else {
                callback(self.readableErrorFromResult(result))
            }
        }
    }
    
    func attemptUpload(upload: ImgurUpload) {
        let headers = [
            "Authorization": isAuthenticated ? "Client-Bearer \(accessToken!)" : "Client-ID \(imgurClientId)"
        ]
        let parameters = [
            "title": upload.imageName,
            "description": "Uploaded by mac2imgur! (https://mileswd.com/mac2imgur)"
        ]
        let files = [
            "image": HTTPFile.Data("image.\(upload.imageExtension)", upload.imageData, nil)
        ]
        Just.post("\(apiURL)/3/image", json: parameters, files: files, headers: headers) { (result: HTTPResult!) -> Void in
            if let link = result.json?.objectForKey("data")?.objectForKey("link") as? String {
                // Update link provided by API to HTTPS if necessary
                upload.link = link.stringByReplacingOccurrencesOfString("http://", withString: "https://")
            } else {
                upload.error = self.readableErrorFromResult(result)
            }
            upload.completionHandler?(upload)
        }
    }
}