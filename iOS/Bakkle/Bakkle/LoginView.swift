//
//  ViewController.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/12/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

import FBSDKLoginKit

class LoginView: UIViewController {
    
    let mainScreenSegueIdentifier = "PushToFeedSegue"
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoImageViewAspectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var loginScreenBkg: UIImageView!
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var emailRegisterBtn: UIButton!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    var background:UIImageView!
    var logo: UIImageView!
    var previousVC: ProfileView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Bakkle.sharedInstance.flavor == Bakkle.GOODWILL ){
            self.logoImageView.image = UIImage(named: "GWLogo_Full@2x.png")!
            logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
            self.loginScreenBkg.image = UIImage(named: "LoginScreen-bkg-blue.png")!
        }
        setupButtons()
    }
    
    func setupButtons(){
        closeBtn.setImage(IconImage().close(), forState: .Normal)
        closeBtn.setTitle("", forState: .Normal)
        self.signInBtn.hidden = false
        self.signInLabel.hidden = false
        self.emailRegisterBtn.hidden = false
        self.facebookBtn.hidden = false
        self.signUpLabel.hidden = false
    }
    
    @IBAction func facebookPressed(sender: UIButton) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], handler: { (result, error) -> Void in
            if error != nil {
                var alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else if result.isCancelled {
                // Run code if the user cancelled the login process
            } else {
                self.signInBtn.hidden = true
                self.signInLabel.hidden = true
                self.emailRegisterBtn.hidden = true
                self.facebookBtn.hidden = true
                self.signUpLabel.hidden = true
                
                // this handles checks for missing information
                self.bakkleLogin()
            }
        })
    }
    
    
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func bakkleLogin() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, first_name, last_name, gender, verified"]).startWithCompletionHandler({ (connection, result2, error) -> Void in
            if error != nil {
                println("error=\(error)")
                return
            } else {
                var verifiedKey = "verified"
                NSLog("User verified = \(result2.objectForKey(verifiedKey))")
                var userid = result2.objectForKey("id") as! String
                var gender = result2.objectForKey("gender") as! String
                var name = result2.objectForKey("name") as! String
                var first_name = result2.objectForKey("first_name") as! String
                var last_name = result2.objectForKey("last_name") as! String
                Bakkle.sharedInstance.account_type = 2
                Bakkle.sharedInstance.facebook(gender, name: name, userid: userid, first_name: first_name, last_name: last_name, success: {
                    // Sucessfully logged in via FB
                    Bakkle.sharedInstance.login({
                        
                        Bakkle.sharedInstance.persistData()
                        
                        // jump into the feedview if successfully logged in
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.previousVC != nil {
                                Bakkle.sharedInstance.getAccount(Bakkle.sharedInstance.account_id, success: {
                                    self.previousVC.user = Bakkle.sharedInstance.responseDict.valueForKey("account") as! NSDictionary
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                    }, fail: {})
                            }else{
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                            
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            // Register for push notifications.
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
                            appDelegate.registerForPushNotifications(UIApplication.sharedApplication())
                        }
                        
                        }, fail: {
                            NSLog("oops")
                    })
                }) // Bakkle.sharedInstance.facebook
            }
        }) // FBSDKGraphRequest completion handler
    }
    
}

