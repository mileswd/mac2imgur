//
//  ImgurClient.swift
//  mac2imgur
//
//  Created by Dexafree on 25/08/14.
//
//

import Foundation

class UploadController {
    
    var pathToImage: String
    var client: ImgurClient?
    let boundary: String = "-----------------------------\(arc4random())\(arc4random())" // Random boundary
    var delegate: ImgurUploadDelegate

    
    init(pathToImage: String, client: ImgurClient, delegate: ImgurUploadDelegate) {
        self.pathToImage = pathToImage
        self.client = client
        self.delegate = delegate
    }
    
    func attemptUpload() {
        
        if client!.isUserLoggedIn! {
            
            if client!.isAccessTokenStillValid() {
                //NSLog("TOKEN IS VALID")
                upload(false)
            } else {
                //NSLog("TOKEN IS NOT VALID")
                client?.requestNewAccessToken({ ()->Void in
                    //NSLog("NEW TOKEN REQUESTED")
                    self.upload(false)
                })
            }
            
        } else {
            //NSLog("Anonymous upload")
            upload(true)
        }
        
    }
    
    func upload(anonymous: Bool){
        //println("Attempting to upload image (\(anonymous))")
        
        let url: NSURL = NSURL.fileURLWithPath(pathToImage)!
        let imageData: NSData = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: "https://api.imgur.com/3/upload")
        request.HTTPMethod = "POST"
        
        let requestBody = NSMutableData()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let clientId: NSString! = client!.imgurClientId
        
        // Add Client-ID authorization
        if anonymous {
        request.addValue("Client-ID \(client?.imgurClientId)", forHTTPHeaderField: "Authorization")
        } else {
            NSLog("ACCESS: (\(client!.accessToken!))")
        request.addValue("Client-Bearer \(client!.accessToken!)", forHTTPHeaderField: "Authorization")
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
        requestBody.appendData("Uploaded by swift2imgur! (\(client!.projectUrl))".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        requestBody.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = requestBody
        
        // Attempt request
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                NSLog("An error occurred: %@", error);
                self.delegate.uploadAttemptCompleted(false, link: "", pathToImage: self.pathToImage)
            } else {
                var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                //println("Received response: \(responseDict)")
                if responseDict.valueForKey("status")?.integerValue == 200 {
                    self.delegate.uploadAttemptCompleted(true, link: responseDict.valueForKey("data")!.valueForKey("link") as String, pathToImage: self.pathToImage)
                } else {
                    self.delegate.uploadAttemptCompleted(false, link: "", pathToImage: self.pathToImage)
                    NSLog("An error occurred (%@): %@", responseDict.valueForKey("status") as String, responseDict);
                }
            }
        })
    }
}
