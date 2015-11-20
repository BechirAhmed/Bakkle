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
        
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        let login = FBSDKLoginManager()
        Bakkle.sharedInstance.account_type = 1
        login.logInWithReadPermissions(["public_profile"], handler: { (result, error) -> Void in
            if error != nil {
                var alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else if result.isCancelled {
                // Run code if the user cancelled the login process
            } else {
                // this handles checks for missing information
                Bakkle.sharedInstance.bakkleLogin({ () -> () in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        })
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
