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

class ImgurClient {
    
    let urlStart = "https://api.imgur.com/oauth2/authorize?client_id="
    let urlEnd = "&response_type=pin&state=active"
    
    let imgurClientId = "5867856c9027819"
    let imgurClientSecret = "7c2a63097cbb0f10f260291aab497be458388a64"
    let projectUrl = "https://github.com/rauix/mac2imgur"
    
    var preferences: PreferencesManager
    
    var loggedIn: Bool = false
    var lastTokenExpiry: NSDate?
    
    var username: String?
    var accessToken: String?
    var refreshToken: String?
    
    init (preferences: PreferencesManager) {
        self.preferences = preferences
        username = preferences.getString(PreferencesConstant.username.rawValue, def: nil)
        refreshToken = preferences.getString(PreferencesConstant.refreshToken.rawValue, def: nil)
        if username != nil && refreshToken != nil {
            loggedIn = true
        }
    }
    
    func openBrowserForAuth() {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: urlStart + imgurClientId + urlEnd)!)
    }
    
    func getTokenFromPin(pin: String, callback: (username: String) -> ()) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.imgur.com/oauth2/token")!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"pin", "pin":pin] as Dictionary
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            let strData: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println("Body: \(strData)")
            var err: NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary {
                if err != nil {
                    NSLog(err!.localizedDescription)
                } else {
                    if let refToken = json["refresh_token"] as? String {
                        self.loggedIn = true
                        self.setAccessToken(json["access_token"] as String)
                        
                        self.username = json["account_username"] as? String
                        
                        self.preferences.setString(PreferencesConstant.refreshToken.rawValue, value: refToken)
                        self.preferences.setString(PreferencesConstant.username.rawValue, value: self.username!)
                        
                        callback(username: self.username!)
                        println("Success: \(refToken)")
                    }
                }
            }
        })
        task.resume()
    }
    
    func requestNewAccessToken(callback: () -> ()) {
        let url: NSURL = NSURL(string: "https://api.imgur.com/oauth2/token")!
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        println("Refresh token \(refreshToken!)")
        
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"refresh_token", "refresh_token":self.refreshToken!] as Dictionary
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> () in
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary {
                if err != nil {
                    NSLog(err!.localizedDescription)
                } else {
                    if let access = json["access_token"] as? String {
                        self.setAccessToken(access)
                        callback()
                    }
                }
            }
        })
        task.resume()
    }
    
    func isAccessTokenValid() -> Bool {
        if self.accessToken != nil {
            let now: NSDate! = NSDate()
            let comparison: NSComparisonResult = self.lastTokenExpiry!.compare(now)
            return comparison == NSComparisonResult.OrderedDescending
        }
        return false
    }
    
    func setAccessToken(token: String) {
        self.accessToken = token
        let secondsInAnHour: NSTimeInterval = 1 * 60 * 60
        let now: NSDate = NSDate()
        self.lastTokenExpiry = now.dateByAddingTimeInterval(secondsInAnHour)
    }
    
    func deleteCredentials() {
        preferences.deleteKey(PreferencesConstant.username.rawValue)
        preferences.deleteKey(PreferencesConstant.refreshToken.rawValue)
        loggedIn = false
    }
}