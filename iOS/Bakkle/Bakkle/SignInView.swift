//
//  SignInView.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 11/13/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import UIKit

import FBSDKLoginKit

class SignInView: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var facebookBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    func setupButtons(){
        closeBtn.setImage(IconImage().close(), forState: .Normal)
        closeBtn.setTitle("", forState: .Normal)
    }
    
    @IBAction func signInPressed(sender: AnyObject) {
        let email = self.emailField.text
        let password = self.passwordField.text
        Bakkle.sharedInstance.account_type = 2
        Bakkle.sharedInstance.localUserID(email, device_uuid: Bakkle.sharedInstance.deviceUUID)
        Bakkle.sharedInstance.authenticateLocal(Bakkle.sharedInstance.facebook_id_str, device_uuid: Bakkle.sharedInstance.deviceUUID, password: password, success: { () -> () in
            Bakkle.sharedInstance.login({ () -> () in
                
                Bakkle.sharedInstance.persistData()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                }, fail: {})
            }, fail: {})
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], handler: { (result, error) -> Void in
            if error != nil {
                var alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else if result.isCancelled {
                // Run code if the user cancelled the login process
            } else {
                // this handles checks for missing information
                self.bakkleLogin(())
            }
        })
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
                Bakkle.sharedInstance.account_type = 1
                Bakkle.sharedInstance.facebook(gender, name: name, userid: userid, first_name: first_name, last_name: last_name, success: {
                    // Sucessfully logged in via FB
                    Bakkle.sharedInstance.login({
                        
                        Bakkle.sharedInstance.persistData()
                        
                        // jump into the feedview if successfully logged in
                        dispatch_async(dispatch_get_main_queue()) {
                            self.dismissViewControllerAnimated(true, completion: nil)
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
    
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
