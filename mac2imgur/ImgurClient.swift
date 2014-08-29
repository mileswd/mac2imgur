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

class ImgurClient: NSObject {
    
    let REFRESH_TOKEN_CONSTANT: NSString! = "refresh_token"
    let USERNAME_CONSTANT: NSString! = "imgur_username"
    let DELETE_SCREENSHOT_AFTER_UPLOAD_CONSTANT: NSString! = "delete_screenshot_after_upload"
    
    var isUserLoggedIn: Bool! = false
    var lastTokenExpiry: NSDate?
    var deleteScreenshotAfterUpload: Bool! = false
    
    var username: NSString?
    var accessToken: NSString?
    var refreshToken: NSString?
    
    let urlStart: NSString! = "https://api.imgur.com/oauth2/authorize?client_id="
    let urlEnd: NSString! = "&response_type=pin&state=active"
    
    let imgurClientId = "5867856c9027819"
    let imgurClientSecret = "7c2a63097cbb0f10f260291aab497be458388a64"
    let projectUrl = "https://github.com/rauix/mac2imgur"
    
    override init(){
        super.init()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        refreshToken = userDefaults.objectForKey(REFRESH_TOKEN_CONSTANT) as NSString?
        username = userDefaults.objectForKey(USERNAME_CONSTANT) as NSString?
        deleteScreenshotAfterUpload = userDefaults.boolForKey(DELETE_SCREENSHOT_AFTER_UPLOAD_CONSTANT)
        if refreshToken != nil {
            isUserLoggedIn = true
        }
        
    }
    
    func hasAccount() -> Bool! {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.objectForKey(REFRESH_TOKEN_CONSTANT) != nil
    }
    
    func openBrowserForAuth() {
        let workspace: NSWorkspace! = NSWorkspace.sharedWorkspace()
        let urlString: NSString! = urlStart + imgurClientId + urlEnd
        let urlNS: NSURL! = NSURL.URLWithString(urlString)
        workspace.openURL(urlNS)
    }
    
    func getTokenFromPin(pin: NSString, closure: (username: NSString)->() ){

        let url: NSURL = NSURL.URLWithString("https://api.imgur.com/oauth2/token")
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
            
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"pin", "pin":pin] as Dictionary
            
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            NSLog("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            NSLog("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
            
            if(err != nil) {
                NSLog(err!.localizedDescription)
            }
            else {
                if let refToken = json["refresh_token"] as NSString? {
                    self.isUserLoggedIn = true
                    self.accessToken = json["access_token"] as NSString?
                    
                    var user = json["account_username"] as NSString?
                    
                    self.saveRefreshToken(refToken)
                    self.saveUserName(user)
                    
                    closure(username: user!)
                    NSLog("Succes: \(refToken)")
                }
            }
        })
        
        task.resume()
        
    }
    
    func requestNewAccessToken(){
        let url: NSURL = NSURL.URLWithString("https://api.imgur.com/oauth2/token")
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"refresh_token", "refresh_token":self.refreshToken!] as Dictionary
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //NSLog("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //NSLog("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
            
            if(err != nil) {
                NSLog(err!.localizedDescription)
            }
            else {
                if let access = json["access_token"] as NSString? {
                    self.setAccessToken(access)
                    //NSLog("Succes: \(access)")
                }
            }
        })
        
        task.resume()

    }
    
    func requestNewAccessToken(closure: ()->Void){
        let url: NSURL = NSURL.URLWithString("https://api.imgur.com/oauth2/token")
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        //NSLog("Refresh token (\(refreshToken))")
        
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"refresh_token", "refresh_token":self.refreshToken!] as Dictionary
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //NSLog("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //NSLog("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
            
            if(err != nil) {
                NSLog(err!.localizedDescription)
            }
            else {
                if let access = json["access_token"] as NSString? {
                    self.setAccessToken(access)
                    closure()
                    //NSLog("Succes: \(access)")
                }
            }
        })
        
        task.resume()
        
    }
    
    func isAccessTokenStillValid() -> Bool {
        
        if self.accessToken == nil {
            //NSLog("Token was nil")
            return false
        }
        
        let now: NSDate! = NSDate()
        
        let comparison: NSComparisonResult! = self.lastTokenExpiry?.compare(now)
        
        if comparison == NSComparisonResult.OrderedDescending {
            
            //NSLog("Token is still valid")
            
            return true
            
        } else {
            
            //NSLog("Token is no longer valid")
            
            return false
            
        }
        
    }
    
    
    func setAccessToken(token: NSString){
        self.accessToken = token
        let secondsInAnHour: NSTimeInterval = 1 * 60 * 60
        let now: NSDate! = NSDate()
        self.lastTokenExpiry = now.dateByAddingTimeInterval(secondsInAnHour)
    }
    
    
    func saveRefreshToken(token: NSString){
        self.refreshToken = token
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: REFRESH_TOKEN_CONSTANT)
    }
    
    func setDeleteScreenshotAfterUpload(delete: Bool!){
        self.deleteScreenshotAfterUpload = delete
        
        NSUserDefaults.standardUserDefaults().setBool(delete, forKey: DELETE_SCREENSHOT_AFTER_UPLOAD_CONSTANT)
    }
    
    func saveUserName(username: NSString?){
        self.username = username
        NSUserDefaults.standardUserDefaults().setValue(username, forKey: USERNAME_CONSTANT)
    }
    
    func deleteCredentials(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(REFRESH_TOKEN_CONSTANT)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(USERNAME_CONSTANT)
        isUserLoggedIn = false
    }
    
    
}