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
    
    let apiUrl = NSURL(string: "https://api.imgur.com/oauth2/token")!
    let urlStart = "https://api.imgur.com/oauth2/authorize?client_id="
    let urlEnd = "&response_type=pin&state=active"
    
    let imgurClientId = "5867856c9027819"
    let imgurClientSecret = "7c2a63097cbb0f10f260291aab497be458388a64"
    let projectUrl = "https://github.com/rauix/mac2imgur"
    
    var preferences: PreferencesManager
    var session: NSURLSession
    
    var authenticated: Bool = false
    var lastTokenExpiry: NSDate?
    
    var username: String?
    var accessToken: String?
    var refreshToken: String?
    
    init (preferences: PreferencesManager) {
        self.preferences = preferences
        session = NSURLSession.sharedSession()
        username = preferences.getString(PreferencesConstant.username.rawValue, def: nil)
        refreshToken = preferences.getString(PreferencesConstant.refreshToken.rawValue, def: nil)
        if username != nil && refreshToken != nil {
            authenticated = true
        }
    }
    
    func openBrowserForAuth() {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: urlStart + imgurClientId + urlEnd)!)
    }
    
    func getTokenFromPin(pin: String, callback: () -> ()) {
        let request = NSMutableURLRequest(URL: apiUrl)
        request.HTTPMethod = "POST"
        
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"pin", "pin":pin]
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary {
                if err != nil {
                    NSLog(err!.localizedDescription)
                } else {
                    if let token = json["refresh_token"] as? String {
                        self.setAccessToken(json["access_token"] as String)
                        self.username = json["account_username"] as? String
                        self.authenticated = true
                        
                        self.preferences.setString(PreferencesConstant.refreshToken.rawValue, value: token)
                        self.preferences.setString(PreferencesConstant.username.rawValue, value: self.username!)
                        
                        callback()
                        println("Success: \(token)")
                    } else {
                        NSLog("An error occurred - the response was invalid: %@", response)
                    }
                }
            }
        })
        task.resume()
    }
    
    func requestNewAccessToken(callback: () -> ()) {
        let request = NSMutableURLRequest(URL: apiUrl)
        request.HTTPMethod = "POST"
        
        println("Refresh token \(refreshToken!)")
        
        let params = ["client_id":imgurClientId, "client_secret":imgurClientSecret, "grant_type":"refresh_token", "refresh_token":self.refreshToken!]
        
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
                    } else {
                        NSLog("An error occurred - the response was invalid: %@", response)
                    }
                }
            }
        })
        task.resume()
    }
    
    func isAccessTokenValid() -> Bool {
        if accessToken != nil {
            let now: NSDate! = NSDate()
            let comparison: NSComparisonResult = lastTokenExpiry!.compare(now)
            return comparison == NSComparisonResult.OrderedDescending
        }
        return false
    }
    
    func setAccessToken(token: String) {
        accessToken = token
        let secondsInAnHour: NSTimeInterval = 1 * 60 * 60
        let now: NSDate = NSDate()
        lastTokenExpiry = now.dateByAddingTimeInterval(secondsInAnHour)
    }
    
    func deleteCredentials() {
        // Delete username and refresh token from defaults
        preferences.deleteKey(PreferencesConstant.username.rawValue)
        preferences.deleteKey(PreferencesConstant.refreshToken.rawValue)
        authenticated = false
    }
    
    // little static function to convert the imgur link given by the api into an HTTPS link
    class func updateLinkToSSL(original_link: String) -> String {
        if (original_link.substringToIndex(advance(original_link.startIndex, 5)) == "http:") {
            return "https" + original_link.substringFromIndex(advance(original_link.startIndex, 4))
        }
        return original_link
    }
}