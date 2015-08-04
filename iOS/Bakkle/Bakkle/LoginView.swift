//
//  ViewController.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/12/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

class LoginView: UIViewController, FBSDKLoginButtonDelegate {
    
    let mainScreenSegueIdentifier = "PushToFeedSegue"
    
    @IBOutlet weak var fbLoginView: FBSDKLoginButton!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoImageViewAspectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var loginScreenBkg: UIImageView!
    
    @IBOutlet weak var signUpLabel: UILabel!
    
    var background:UIImageView!
    var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.userInteractionEnabled = true
        
        if (Bakkle.sharedInstance.flavor == Bakkle.GOODWILL ){
            self.logoImageView.image = UIImage(named: "GWLogo_Full@2x.png")!
            logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
            self.loginScreenBkg.image = UIImage(named: "LoginScreen-bkg-blue.png")!
        }
        
        // FBSDK documentation specifically says to not place "publish_actions" in readPermissions... it WILL NOT run
        self.fbLoginView.readPermissions = ["email"]
        
        // add the image, making the login view looks like the launch screen when user already logged in
        setBackgroundImg()
        setLogoImg()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // check if the user already logged in, if not, set the background image to transparent
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.fbLoginView.hidden = true
            self.fbLoginView.userInteractionEnabled = false
            self.signUpLabel.hidden = true
            
            background.hidden = false
            view.userInteractionEnabled = false
            bakkleLogin()
        } else {
            self.fbLoginView.hidden = false
            self.fbLoginView.userInteractionEnabled = true
            self.signUpLabel.hidden = false
            
            background.hidden = true
            view.userInteractionEnabled = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fbLoginView.sizeToFit()
    }
    
    // create the background image, which is the same as the launch screen background
    func setBackgroundImg(){
        if Bakkle.sharedInstance.flavor == Bakkle.GOODWILL {
            background = UIImageView(image: UIImage(named: "SplashScreen-bkg-Blue.png"))
        } else{
            background = UIImageView(image: UIImage(named: "SplashScreen-bkg.png"))
        }
        background.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.view.addSubview(background)
    }
    
    // create the logo image, which is the same as the launch screen logo
    func setLogoImg(){
        if Bakkle.sharedInstance.flavor == Bakkle.GOODWILL {
            logo = UIImageView(image: UIImage(named: "GWLogo_Full@2x.png"))
            logo.contentMode = UIViewContentMode.ScaleAspectFit
            logo.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: logo, attribute: NSLayoutAttribute.Height, multiplier: 2, constant: 0.0))
        }else{
            logo = UIImageView(image: UIImage(named: "logo-white-design-clear.png"))
            logo.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: logo, attribute: NSLayoutAttribute.Width, multiplier: 25.0/62.0, constant: 0.0))
        }
        background.addSubview(logo)
        
        logo.setTranslatesAutoresizingMaskIntoConstraints(false)
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 49.0))
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 36.0))
    }
    
    func bakkleLogin() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name, first_name, last_name, email, gender, verified"]).startWithCompletionHandler({ (connection, result2, error) -> Void in
            if error != nil {
                // Process error
                var alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                var verifiedKey = "verified"
                NSLog("User verified = \(result2.objectForKey(verifiedKey))")
                if (result2.objectForKey("verified") as! Bool && result2.objectForKey("email") != nil) {
                    var userid = result2.objectForKey("id") as! String
                    var email = result2.objectForKey("email") as! String
                    var gender = result2.objectForKey("gender") as! String
                    var name = result2.objectForKey("name") as! String
                    var first_name = result2.objectForKey("first_name") as! String
                    var last_name = result2.objectForKey("last_name") as! String
                    Bakkle.sharedInstance.facebook(email, gender: gender, name: name, userid: userid, first_name: first_name, last_name: last_name, success: {
                        // Sucessfully logged in via FB
                        Bakkle.sharedInstance.login({
                            
                            // jump into the feedview if successfully logged in
                            dispatch_async(dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier(self.mainScreenSegueIdentifier, sender: self)
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                // Register for push notifications.
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
                                appDelegate.registerForPushNotifications(UIApplication.sharedApplication())
                            }
                            
                            }, fail: {})
                    }) // Bakkle.sharedInstance.facebook
                } else if !(result2.objectForKey(verifiedKey) as! Bool) {
                    // handle unverified log in
                    
                    /*
                    ** NOTE: A verified account is one that has successfully completed Facebook's verification process here: https://developers.facebook.com/docs/graph-api/reference/user#Reading
                    ** Then proceed to scroll down the page to find the verified variable.
                    */
                    
                    FBSDKLoginManager().logOut()
                    FBSDKAccessToken.setCurrentAccessToken(nil)
                    var alert = UIAlertController(title: "Warning", message: "Your Facebook account has not been verified.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    FBSDKLoginManager().logOut()
                    FBSDKAccessToken.setCurrentAccessToken(nil)
                    self.performSegueWithIdentifier("EmailRequiredSegue", sender: self)
                }
            } // else
        }) // FBSDKGraphRequest completion handler
    }
    
    /* FBSDKLoginButton Protocol Methods */
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            // Process error
            var alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if result.isCancelled {
            // Run code if the user cancelled the login process
        } else {
            self.fbLoginView.userInteractionEnabled = false
            self.fbLoginView.hidden = true
            self.signUpLabel.hidden = true
            
            // this handles checks for missing information
            bakkleLogin()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // Should never be called, login page is inaccessible when logged in
    }
    
}

