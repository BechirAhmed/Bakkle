//
//  SigUpView.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 11/20/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

//
//  SignInView.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 11/13/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import UIKit

import FBSDKLoginKit

class SignUpView: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var editBtn: UIImageView!
    
    var kbHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        
        //text field delegates
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setupProfileImg()
    }
   
    func dismissKeyboard() {
        self.nameField.resignFirstResponder() || self.emailField.resignFirstResponder() || self.passwordField.resignFirstResponder() || self.confirmPasswordField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 150)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 150)
    }
    
    func animateViewMoving(up: Bool, moveValue: CGFloat) {
        let movementDuration = 0.5
        let movement = up ? -moveValue : moveValue
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    func setupButtons(){
        closeBtn.setImage(IconImage().close(), forState: .Normal)
        closeBtn.setTitle("", forState: .Normal)
        editBtn.image = IconImage().edit(UIColor.blackColor())
    }
    
    func setupProfileImg() {
//        if Bakkle.sharedInstance.account_type == 0 || Bakkle.sharedInstance.profileImgURL == nil {
            self.profileImg.image = UIImage(named: "default_profile")
//        }else{
//            self.profileImg.hnk_setImageFromURL(Bakkle.sharedInstance.profileImgURL!)
//        }
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width/2
        self.profileImg.layer.borderWidth = 8.0
        self.profileImg.clipsToBounds = true
        let borderColor = UIColor.grayColor()
        self.profileImg.layer.borderColor = borderColor.CGColor
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
//        let email = self.emailField.text
//        let password = self.passwordField.text
//        Bakkle.sharedInstance.account_type = 2
//        Bakkle.sharedInstance.localUserID(email, device_uuid: Bakkle.sharedInstance.deviceUUID)
//        Bakkle.sharedInstance.authenticateLocal(Bakkle.sharedInstance.facebook_id_str, device_uuid: Bakkle.sharedInstance.deviceUUID, password: password, success: { () -> () in
//            Bakkle.sharedInstance.login({ () -> () in
//                
//                Bakkle.sharedInstance.persistData()
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.dismissViewControllerAnimated(true, completion: nil)
//                })
//                }, fail: {})
//            }, fail: {})
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
