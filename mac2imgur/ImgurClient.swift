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
    
    let boundary: String = "---------------------\(arc4random())\(arc4random())" // Random boundary
    let apiUrl = "https://api.imgur.com/"

    var uploadQueue = [ImgurUpload]()
    var authenticationInProgress: Bool = false
    var lastTokenExpiry: NSDate?
    
    var username: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(kUsername)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kUsername)
        }
    }
    
    var refreshToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(kRefreshToken)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kRefreshToken)
        }
    }
    
    var accessToken: String? {
        didSet {
            // Update token expiry date
            let secondsInAnHour: NSTimeInterval = 1 * 60 * 60
            let now: NSDate = NSDate()
            lastTokenExpiry = now.dateByAddingTimeInterval(secondsInAnHour)
        }
    }
    
    var isAuthenticated: Bool {
        return username != nil && refreshToken != nil
    }
    
    var accessTokenIsValid: Bool {
        if accessToken != nil {
            let comparison: NSComparisonResult = lastTokenExpiry!.compare(NSDate())
            return comparison == NSComparisonResult.OrderedDescending
        }
        return false
    }
    
    func getTokensFromPin(pin: String, callback: () -> ()) {
        let parameters = [
            "client_id": imgurClientId,
            "client_secret": imgurClientSecret,
            "grant_type": "pin",
            "pin": pin
        ]
        request(.POST, "\(apiUrl)oauth2/token", parameters: parameters, encoding: .JSON)
            .validate()
            .validate(contentType: ["application/json"])
            .responseJSON { (request, response, JSON, error) -> Void in
                if let refreshToken = JSON?["refresh_token"] as? String {
                    self.accessToken = JSON?["access_token"] as? String
                    self.username = JSON?["account_username"] as? String
                    self.refreshToken = refreshToken
                    callback()
                } else {
                    NSLog("An error occurred while attempting to obtain tokens from a pin: \(error)\nRequest: \(request)\nResponse: \(response)")
                }
        }
    }
    
    func requestAccessToken(callback: () -> ()) {
        let parameters = [
            "client_id": imgurClientId,
            "client_secret": imgurClientSecret,
            "grant_type": "refresh_token",
            "refresh_token": self.refreshToken!
        ]
        request(.POST, "\(apiUrl)oauth2/token", parameters: parameters, encoding: .JSON)
            .validate()
            .validate(contentType: ["application/json"])
            .responseJSON { (request, response, JSON, error) -> Void in
            if let access = JSON?["access_token"] as? String {
                self.accessToken = access
                callback()
            } else {
                NSLog("An error occurred while requesting a new access token: \(error)\nRequest: \(request)\nResponse: \(response)")
            }
        }
    }
    
    func deleteCredentials() {
        // Delete username and refresh token from defaults
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUsername)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRefreshToken)
    }
    
    func addToQueue(upload: ImgurUpload) {
        uploadQueue.append(upload)
        
        if isAuthenticated {
            // If necessary, request a new access token
            if accessTokenIsValid {
                processQueue()
            } else {
                if !authenticationInProgress {
                    authenticationInProgress = true
                    requestAccessToken({ () -> () in
                        self.authenticationInProgress = false
                        self.processQueue()
                    })
                }
            }
        } else {
            processQueue()
        }
    }
    
    func processQueue() {
        // Upload all images in queue
        for upload in uploadQueue {
            attemptUpload(upload)
        }
        // Clear queue
        uploadQueue.removeAll(keepCapacity: false)
    }
    
    func attemptUpload(uploadRequest: ImgurUpload) {
        let url: NSURL = NSURL(fileURLWithPath: uploadRequest.imagePath)!
        let imageData: NSData = NSData(contentsOfURL: url, options: nil, error: nil)!
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: "\(apiUrl)3/upload")
        request.HTTPMethod = Method.POST.rawValue
        
        let requestBody = NSMutableData()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Add authorization
        request.addValue(isAuthenticated ? "Client-Bearer \(accessToken!)" : "Client-ID \(imgurClientId)", forHTTPHeaderField: "Authorization")
        
        // Add image data
        requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Disposition: attachment; name=\"image\"; filename=\".\(uploadRequest.imagePath.pathExtension)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData(imageData)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // Add title
        requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Disposition: form-data; name=\"title\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData(uploadRequest.imagePath.lastPathComponent.stringByDeletingPathExtension.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // Add description
        requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Disposition: form-data; name=\"description\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Uploaded by mac2imgur! (https://mac2imgur.mileswd.com)".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        requestBody.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // Send request
        upload(request, requestBody)
            .validate()
            .validate(contentType: ["application/json"])
            .responseJSON { (request, response, JSON, error) -> Void in
                if var link = JSON?.objectForKey("data")?.objectForKey("link") as? String {
                    // Update link provided by API to HTTPS if necessary
                    if link.substringToIndex(advance(link.startIndex, 5)) == "http:" {
                        link = "https" + link.substringFromIndex(advance(link.startIndex, 4))
                    }
                    uploadRequest.link = link
                } else {
                    NSLog("An error occurred while attempting to upload an image: \(error)\nRequest: \(request)\nResponse: \(response)")
                }
                uploadRequest.callback(upload: uploadRequest)
        }
    }
}