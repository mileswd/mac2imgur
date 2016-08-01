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

class UserNotificationController: NSObject, NSUserNotificationCenterDelegate {
    
    static let shared = UserNotificationController()
    
    // MARK: NSUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        // Open URL if present in the informativeText field of a notification
        if let text = notification.informativeText, let url = URL(string: text) {
            NSWorkspace.shared().open(url)
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // Always present notifications
        return true
    }
    
    // MARK: General
    
    func displayNotification(title: String, informativeText: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = informativeText
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func displayNotification(withTitle title: String, error: Error?) {
        displayNotification(title: title,
                            informativeText: error?.localizedDescription ?? "An unknown error occurred")
    }
    
}
