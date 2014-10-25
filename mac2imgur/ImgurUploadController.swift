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

class ImgurUploadController {
    
    let client: ImgurClient
    var uploadQueue: [ImgurUpload]
    var authenticationInProgress: Bool
    
    init(imgurClient: ImgurClient) {
        self.client = imgurClient
        self.uploadQueue = [ImgurUpload]()
        self.authenticationInProgress = false
    }
    
    func addToQueue(upload: ImgurUpload) {
        uploadQueue.append(upload)
        
        if client.loggedIn {
            // If necessary, request a new access token
            if client.isAccessTokenValid() {
                processQueue(true)
            } else {
                if !authenticationInProgress {
                    authenticationInProgress = true
                    self.client.requestNewAccessToken({ () -> () in
                        self.authenticationInProgress = false
                        self.processQueue(true)
                    })
                }
            }
        } else {
            processQueue(false)
        }
    }
    
    func processQueue(authenticated: Bool) {
        // Upload all images in queue
        for upload in uploadQueue {
            upload.attemptUpload(authenticated)
        }
        // Clear queue
        uploadQueue.removeAll(keepCapacity: false)
    }
    
}