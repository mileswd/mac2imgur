//
//  ImgurClient.swift
//  mac2imgur
//
//  Created by Dexafree on 25/08/14.
//
//

import Cocoa

class ImgurClient: NSObject {
    
    let REFRESH_TOKEN_CONSTANT: NSString! = "refresh_token"
    let USERNAME_CONSTANT: NSString! = "imgur_username"
    
    var isUserLoggedIn: Bool! = false
    var lastTokenExpiry: NSDate?
    
    var username: NSString?
    var accessToken: NSString?
    var refreshToken: NSString?
    
    let urlStart: NSString! = "https://api.imgur.com/oauth2/authorize?client_id="
    let urlEnd: NSString! = "&response_type=pin&state=active"
    
    let imgurClientId = "fa5eb2e5869b836"
    let imgurClientSecret = "905fc35122f45819a1883dd2d51dca22fc2642b8"
    let projectUrl = "https://github.com/dexafree/swift2imgur"
    
    override init(){
        super.init()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        refreshToken = userDefaults.objectForKey(REFRESH_TOKEN_CONSTANT) as NSString?
        username = userDefaults.objectForKey(USERNAME_CONSTANT) as NSString?
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
            NSLog("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            NSLog("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
            
            if(err != nil) {
                NSLog(err!.localizedDescription)
            }
            else {
                if let access = json["access_token"] as NSString? {
                    self.setAccessToken(access)
                    NSLog("Succes: \(access)")
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
        
        NSLog("Refresh token (\(refreshToken))")
        
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"refresh_token", "refresh_token":self.refreshToken!] as Dictionary
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //NSLog("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            NSLog("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
            
            if(err != nil) {
                NSLog(err!.localizedDescription)
            }
            else {
                if let access = json["access_token"] as NSString? {
                    self.setAccessToken(access)
                    closure()
                    NSLog("Succes: \(access)")
                }
            }
        })
        
        task.resume()
        
    }
    
    func isAccessTokenStillValid() -> Bool {
        
        if self.accessToken == nil {
            NSLog("Token was nil")
            return false
        }
        
        let now: NSDate! = NSDate()
        
        let comparison: NSComparisonResult! = self.lastTokenExpiry?.compare(now)
        
        if comparison == NSComparisonResult.OrderedDescending {
            
            NSLog("Token is still valid")
            
            return true
            
        } else {
            
            NSLog("Token is no longer valid")
            
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
    
    func saveUserName(username: NSString?){
        self.username = username
        NSUserDefaults.standardUserDefaults().setValue(username, forKey: USERNAME_CONSTANT)
    }
    
    func deleteCredentials(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(REFRESH_TOKEN_CONSTANT)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(USERNAME_CONSTANT)
    }
    
    
}