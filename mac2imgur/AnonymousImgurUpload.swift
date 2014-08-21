//
//  AppDelegate.swift
//  mac2imgur
//

import Foundation

class AnonymousImgurUpload {
    
    let clientId: String = "5867856c9027819"
    let supportUrl: String = "https://github.com/rauix/mac2imgur"
    let boundary: String = "-----------------------------\(arc4random())\(arc4random())" // Random boundary
    var pathToImage: String
    var delegate: AnonymousImgurUploadDelegate
    
    init(pathToImage: String, delegate: AnonymousImgurUploadDelegate) {
        self.pathToImage = pathToImage
        self.delegate = delegate
    }
    
    func attemptUpload() {
        println("Attempting to upload image")
        
        let url: NSURL = NSURL.fileURLWithPath(pathToImage)!
        let imageData: NSData = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: "https://api.imgur.com/3/upload")
        request.HTTPMethod = "POST"
        
        let requestBody = NSMutableData()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Add Client-ID authorization
        request.addValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        
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
        requestBody.appendData("Uploaded by mac2imgur! (\(supportUrl))".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        requestBody.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = requestBody
        
        // Attempt request
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                NSLog("An error occurred: %@", error);
                self.delegate.uploadAttemptCompleted(false, link: "")
            } else {
                var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                println("Received response: \(responseDict)")
                if responseDict.valueForKey("status")?.integerValue == 200 {
                    self.delegate.uploadAttemptCompleted(true, link: responseDict.valueForKey("data")!.valueForKey("link") as String)
                } else {
                    self.delegate.uploadAttemptCompleted(false, link: "")
                    NSLog("An error occurred (%@): %@", responseDict.valueForKey("status") as String, responseDict);
                }
            }
        })
    }
}

protocol AnonymousImgurUploadDelegate {
    func uploadAttemptCompleted(successful: Bool, link: String) -> ()
}