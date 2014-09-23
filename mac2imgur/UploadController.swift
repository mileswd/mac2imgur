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

class UploadController {
    
    var pathToImage: String
    var client: ImgurClient
    let boundary: String = "---------------------\(arc4random())\(arc4random())" // Random boundary
    var callback: (successful: Bool, link: String, pathToImage: String) -> ()
    
    
    init(pathToImage: String, client: ImgurClient, callback: (successful: Bool, link: String, pathToImage: String) -> ()) {
        self.pathToImage = pathToImage
        self.client = client
        self.callback = callback
    }
    
    func attemptUpload() {
        
        if client.loggedIn {
            
            if client.isAccessTokenValid() {
                upload(false)
            } else {
                client.requestNewAccessToken({ () -> Void in
                    self.upload(false)
                })
            }
        } else {
            upload(true)
        }
        
    }
    
    func upload(anonymous: Bool) {
        
        println("Uploading image as authenticated user: \(!anonymous)")
        
        let url: NSURL = NSURL.fileURLWithPath(pathToImage)!
        let imageData: NSData = NSData(contentsOfURL: url, options: nil, error: nil)!
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: "https://api.imgur.com/3/upload")
        request.HTTPMethod = "POST"
        
        let requestBody = NSMutableData()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Add Client-ID authorization
        if anonymous {
            request.addValue("Client-ID \(client.imgurClientId)", forHTTPHeaderField: "Authorization")
        } else {
            println("Access token: \(client.accessToken!)")
            request.addValue("Client-Bearer \(client.accessToken!)", forHTTPHeaderField: "Authorization")
        }
        
        // Add image data
        requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Disposition: attachment; name=\"image\"; filename=\".\(pathToImage.pathExtension)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        requestBody.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData(imageData)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // Add title
        requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Disposition: form-data; name=\"title\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData(pathToImage.lastPathComponent.stringByDeletingPathExtension.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // Add description
        requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Disposition: form-data; name=\"description\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Uploaded by mac2imgur! (\(client.projectUrl))".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        requestBody.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = requestBody
        
        // Attempt request
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                NSLog("An error occurred: %@", error);
                self.callback(successful: false, link: "", pathToImage: self.pathToImage)
            } else {
                var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                println("Received response: \(responseDict)")
                if responseDict.valueForKey("status")?.integerValue == 200 {
                    self.callback(successful: true, link: responseDict.valueForKey("data")!.valueForKey("link") as String, pathToImage: self.pathToImage)
                } else {
                    self.callback(successful: false, link: "", pathToImage: self.pathToImage)
                    NSLog("An error occurred (%@): %@", responseDict.valueForKey("status") as String, responseDict);
                }
            }
        })
    }
}
