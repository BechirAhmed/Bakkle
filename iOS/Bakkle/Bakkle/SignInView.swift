//
//  SignInView.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 11/13/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import UIKit

import FBSDKLoginKit

class SignInView: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    var parentLoginInVC: LoginView? = nil
    var profileVC: ProfileView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        
        //text field delegates
        emailField.delegate = self
        passwordField.delegate = self

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        signInBtn.enabled = false
        signInBtn.setTitleColor(AddItem.CONFIRM_BUTTON_DISABLED_COLOR, forState: .Normal)


    }
    
    func setupButtons(){
        closeBtn.setImage(IconImage().close(), forState: .Normal)
        closeBtn.setTitle("", forState: .Normal)
    }
    
    func dismissKeyboard() {
        self.emailField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }
    
    func disableButtonHandler() {
        if self.emailField.text!.isEmpty || self.passwordField.text!.isEmpty {
            signInBtn.enabled = false
            signInBtn.setTitleColor(AddItem.CONFIRM_BUTTON_DISABLED_COLOR, forState: .Normal)
        }else{
            signInBtn.enabled = true
            signInBtn.setTitleColor(AddItem.BAKKLE_GREEN_COLOR, forState: .Normal)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.disableButtonHandler()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.disableButtonHandler()
    }
    
    @IBAction func signInPressed(sender: AnyObject) {
        self.dismissKeyboard()
        let email = self.emailField.text
        let password = self.passwordField.text
        Bakkle.sharedInstance.account_type = Bakkle.bkAccountTypeEmail
        Bakkle.sharedInstance.localUserID(email!, device_uuid: Bakkle.sharedInstance.deviceUUID) {
        Bakkle.sharedInstance.authenticateLocal(Bakkle.sharedInstance.facebook_id_str, device_uuid: Bakkle.sharedInstance.deviceUUID, password: password!, success: { () -> () in
            Bakkle.sharedInstance.login({ () -> () in
                Bakkle.sharedInstance.persistData()
                if self.profileVC != nil {
                    Bakkle.sharedInstance.getAccount(Bakkle.sharedInstance.account_id, success: { (account: NSDictionary) -> () in
                        self.profileVC!.user = account
                        self.dismissViewControllerAnimated(true, completion: nil)
                        if self.parentLoginInVC != nil {
                            self.parentLoginInVC?.dismissViewControllerAnimated(false, completion: nil)
                        }
                        }, fail: {})
                }else{
                    self.dismissViewControllerAnimated(true, completion: nil)
                    if self.parentLoginInVC != nil {
                        self.parentLoginInVC?.dismissViewControllerAnimated(false, completion: nil)
                    }
                    
                }

                
                }, fail: {})
            }, fail: {
                
                let alert = UIAlertController(title: "Password is not correct", message: "The given password is not correct. Please login again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], handler: { (result, error) -> Void in
            if error != nil {
                let alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)
                })
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
                print("error=\(error)")
                return
            } else {
                let verifiedKey = "verified"
                NSLog("User verified = \(result2.objectForKey(verifiedKey))")
                let userid = result2.objectForKey("id") as! String
                let gender = result2.objectForKey("gender") as! String
                let name = result2.objectForKey("name") as! String
                let first_name = result2.objectForKey("first_name") as! String
                let last_name = result2.objectForKey("last_name") as! String
                Bakkle.sharedInstance.account_type = Bakkle.bkAccountTypeFacebook
                Bakkle.sharedInstance.facebook(gender, name: name, userid: userid, first_name: first_name, last_name: last_name, success: {
                    // Sucessfully logged in via FB
                    Bakkle.sharedInstance.login({
                        
                        Bakkle.sharedInstance.persistData()
                        
                        // jump into the feedview if successfully logged in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            // Register for push notifications.
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
                            appDelegate.registerForPushNotifications(UIApplication.sharedApplication())
                        }
                        
                        }, fail: {
                            NSLog("oops")
                    })
                    }, fail: {}) // Bakkle.sharedInstance.facebook
            }
        }) // FBSDKGraphRequest completion handler
    }
    
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
