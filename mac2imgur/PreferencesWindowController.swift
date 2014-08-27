//
//  PreferencesWindowController.swift
//  mac2imgur
//
//  Created by Dexafree on 25/08/14.
//
//

import Cocoa

class PreferencesWindowController : NSWindowController {
    
    var imgurSession: ImgurClient!

    @IBOutlet weak var signInButton: NSButton!
    @IBOutlet weak var pinCodeField: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var deleteScreenshotAfterUploadButton: NSButton!
    
    
    override init() {

        super.init()
    
    }
    
    override init(window: NSWindow?) {
    
        super.init(window: window)
        
        if self.window? != nil {
        
            self.window!.releasedWhenClosed = false
        
        }

    }
    
    
    required init(coder aDecoder: NSCoder!){
    
        super.init(coder: aDecoder)
    
    }
    
    
    override func showWindow(sender: AnyObject!) {
        
        super.showWindow(sender)
        
        if imgurSession.isUserLoggedIn! {
        
            setWindowForLoggedUser(imgurSession.username!)
        
        }
        
        if imgurSession.deleteScreenshotAfterUpload! {
            deleteScreenshotAfterUploadButton.state = NSOnState
        }
    
    }
    
    
    /*
     * Disables the "Sign in" button, as the user won't be signing in again
     * Enables the PIN Code field and the Save button
     * Loads the AUTH URL with the default browser
     */
    @IBAction func signInButtonClick(sender: AnyObject) {
    
        if imgurSession.isUserLoggedIn == true {
            
            imgurSession.deleteCredentials()
            self.setWindowForAnonymousUser()

        } else {
        
            signInButton!.enabled = false
            pinCodeField!.enabled = true
            
            saveButton!.enabled = true
            imgurSession.openBrowserForAuth()
        
        }
    
    }
    
    
    @IBAction func onDeleteScreenshotAfterUploadButtonPress(sender: AnyObject) {
        
        if deleteScreenshotAfterUploadButton.state == NSOnState {
            
            imgurSession.setDeleteScreenshotAfterUpload(true)
        
        } else {
        
            imgurSession.setDeleteScreenshotAfterUpload(false)
        
        }
        
    }
    
    
    /*
     * Loads the text written at the PIN Code field, and starts
     * the authentication process
     *
     * If the process is successful, it sets the "Sign in" button text
     * to "Sign out", and shows the username in a label placed at the
     * bottom of the screen
     */
    @IBAction func onSaveButtonClick(sender: AnyObject) {
        
        if let pinCode: NSString? = pinCodeField.stringValue {
            
            NSLog("PINCODE: \(pinCode!)")
            imgurSession.getTokenFromPin(pinCode!, closure: { username in
                dispatch_async(dispatch_get_main_queue()) {
                    self.setWindowForLoggedUser(username)
                }
                
            })
            
        }
        
    }
    
    
    func setWindowForLoggedUser(username: NSString){
        
        self.signInButton!.title = "Sign out (\(username))"
        self.signInButton!.enabled = true
        
        self.pinCodeField!.hidden = true
        self.saveButton!.hidden = true
    
    }
    
    func setWindowForAnonymousUser(){
        
        self.signInButton!.title = "1. Sign in"
        self.signInButton!.enabled = true
        
        self.pinCodeField!.stringValue = ""
        self.pinCodeField!.enabled = false
        self.pinCodeField!.hidden = false
        self.saveButton!.enabled = false
        self.saveButton!.hidden = false
    
    }
    
}