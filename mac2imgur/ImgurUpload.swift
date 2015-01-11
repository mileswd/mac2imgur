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

class ImgurUpload {
    
    let boundary: String = "---------------------\(arc4random())\(arc4random())" // Random boundary
    var pathToImage: String
    var isScreenshot: Bool
    var client: ImgurClient
    var delegate: UploadControllerDelegate
    
    init(pathToImage: String, isScreenshot: Bool, client: ImgurClient, delegate: UploadControllerDelegate) {
        self.pathToImage = pathToImage
        self.isScreenshot = isScreenshot
        self.client = client
        self.delegate = delegate
    }
    
    func attemptUpload(authenticated: Bool) {
        
        println("Uploading image as " + (authenticated ? "authenticated" : "anonymous") + " user")
        
        let url: NSURL = NSURL(fileURLWithPath: pathToImage)!
        let imageData: NSData = NSData(contentsOfURL: url, options: nil, error: nil)!
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: "https://api.imgur.com/3/upload")
        request.HTTPMethod = "POST"
        
        let requestBody = NSMutableData()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Add Client-ID authorization
        if authenticated {
            println("Access token: \(client.accessToken!)")
            request.addValue("Client-Bearer \(client.accessToken!)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Client-ID \(client.imgurClientId)", forHTTPHeaderField: "Authorization")
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
                NSLog(error!.localizedDescription);
                self.delegate.uploadAttemptCompleted(false, isScreenshot: self.isScreenshot, link: "", deleteHash: "", pathToImage: self.pathToImage)
            } else {
                if let responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary {
                    println("Received response: \(responseDict)")
                    if responseDict.valueForKey("status") != nil && responseDict.valueForKey("status")?.integerValue == 200 {
                        self.delegate.uploadAttemptCompleted(true, isScreenshot: self.isScreenshot, link: responseDict.valueForKey("data")!.valueForKey("link") as String, deleteHash: responseDict.valueForKey("data")!.valueForKey("deletehash") as String, pathToImage: self.pathToImage)
                    } else {
                        NSLog("An error occurred: %@", responseDict);
                        self.delegate.uploadAttemptCompleted(false, isScreenshot: self.isScreenshot, link: "", deleteHash: "", pathToImage: self.pathToImage)
                    }
                } else {
                    NSLog("An error occurred - the response was invalid: %@", response)
                    self.delegate.uploadAttemptCompleted(false, isScreenshot: self.isScreenshot, link: "", deleteHash: "", pathToImage: self.pathToImage)
                }
            }
        })
    }
}