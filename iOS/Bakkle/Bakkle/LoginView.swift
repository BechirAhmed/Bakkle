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
                Bakkle.sharedInstance.bakkleLogin({ () -> () in
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
                })
            }
        })
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}

