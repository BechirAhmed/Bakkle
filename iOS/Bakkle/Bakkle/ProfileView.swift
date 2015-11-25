//
//  Settings.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Haneke
import FBSDKLoginKit

class ProfileView: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var backgroundAvatar: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    var canEdit = true
    var user: NSDictionary!
    var keyboardHeight:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Bakkle.sharedInstance.flavor == Bakkle.GOODWILL){
            self.view.backgroundColor = Bakkle.sharedInstance.theme_base
            self.editBtn.backgroundColor = Bakkle.sharedInstance.theme_base
            self.logoutBtn.backgroundColor = Bakkle.sharedInstance.theme_base
            self.saveBtn.backgroundColor = Bakkle.sharedInstance.theme_base
        }
        
        setupButtons()
        self.backgroundAvatar.contentMode = UIViewContentMode.ScaleAspectFill
        self.backgroundAvatar.clipsToBounds = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
        
        let center = NSNotificationCenter.defaultCenter() as NSNotificationCenter
        center.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        if canEdit {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }else{
            editBtn.hidden = true
            logoutBtn.hidden = true
            titleLabel.text = "PROFILE"
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupButtons() {
        if !canEdit {
            menuBtn.hidden = true
            closeBtn.hidden = false
            closeBtn.setImage(IconImage().close(), forState: .Normal)
            closeBtn.setTitle("", forState: .Normal)
        }else {
            menuBtn.setImage(IconImage().menu(), forState: .Normal)
            menuBtn.setTitle("", forState: .Normal)
        }
    }
    
    func dismissKeyboard() {
        self.descriptionTextView.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if Bakkle.sharedInstance.account_type == Bakkle.bkAccountTypeGuest {
            setGuestInfo()
        }else{
            setUserInfo()
        }
    }
    
    func setGuestInfo(){
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.backgroundAvatar.hnk_setImageFromURL(NSURL(string: Bakkle.sharedInstance.profileImageURL())!)
                    self.avatar.hnk_setImageFromURL(NSURL(string: Bakkle.sharedInstance.profileImageURL())!)
                     self.setImageAttributes()
                }
        }
        self.nameLabel.text = "Guest"
        self.editBtn.enabled = false
        self.editBtn.backgroundColor = AddItem.CONFIRM_BUTTON_DISABLED_COLOR
        self.logoutBtn.setTitle("LOGIN", forState: UIControlState.Normal)
        
        descriptionTextView.textColor = AddItem.DESCRIPTION_PLACEHOLDER_COLOR
        descriptionTextView.text = "DESCRIPTION"
        
    }
    
    func setUserInfo() {
        let facebook_id = user.valueForKey("facebook_id") as! String
        println("facebook_id: \(facebook_id)")
        let imgURL = NSURL(string: user.valueForKey("avatar_image_url") as! String + "?width=300&height=300")!
        
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                    println("[SettingsView] displaying image \(imgURL)")
                        self.backgroundAvatar.hnk_setImageFromURL(imgURL)
                        self.avatar.hnk_setImageFromURL(imgURL)
                    
                     self.setImageAttributes()
                }
        }
        self.nameLabel.text = user.valueForKey("display_name") as? String
        self.editBtn.enabled = true
        self.editBtn.backgroundColor = Theme.ColorGreen
        
        self.descriptionTextView.text = user.valueForKey("description") as? String
        if descriptionTextView.text.isEmpty {
            descriptionTextView.textColor = AddItem.DESCRIPTION_PLACEHOLDER_COLOR
            descriptionTextView.text = "DESCRIPTION"
        }else {
            descriptionTextView.textColor = UIColor.blackColor()
        }
    }
    
    func setImageAttributes(){
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = self.backgroundAvatar.frame
        self.backgroundAvatar.addSubview(visualEffectView)
        
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width/2
        self.avatar.layer.borderWidth = 7.0
        self.avatar.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    @IBAction func btnLogout(sender: AnyObject) {
        if Bakkle.sharedInstance.account_type == Bakkle.bkAccountTypeGuest {
            self.logoutBtn.setTitle("LOG OUT", forState: UIControlState.Normal)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            vc.previousVC = self
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrentAccessToken(nil)
            Bakkle.sharedInstance.account_type = Bakkle.bkAccountTypeGuest
            Bakkle.sharedInstance.logout({ () -> () in
                Bakkle.sharedInstance.facebook("", name: "Guest User", userid: Bakkle.sharedInstance.guest_id_str, first_name: "Guest", last_name: "User", success: { () -> () in
                    Bakkle.sharedInstance.login({
                        Bakkle.sharedInstance.populateFeed({})
                        }, fail: {})
                    
                    }, fail:{})
                
            })
            setGuestInfo()
        }
    }
    
    @IBAction func btnEdit(sender: AnyObject) {
        editBtn.hidden = true
        logoutBtn.hidden = true
        saveBtn.hidden = false
        descriptionTextView.editable = true
        descriptionTextView.becomeFirstResponder()
        if descriptionTextView.textColor == AddItem.DESCRIPTION_PLACEHOLDER_COLOR {
            descriptionTextView.textColor = UIColor.blackColor()
            descriptionTextView.text = ""
        }
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        editBtn.hidden = false
        logoutBtn.hidden = false
        saveBtn.hidden = true
        descriptionTextView.editable = false
        Bakkle.sharedInstance.setDescription(descriptionTextView.text, success: {}, fail: {})
        if descriptionTextView.text.isEmpty {
            descriptionTextView.textColor = AddItem.DESCRIPTION_PLACEHOLDER_COLOR
            descriptionTextView.text = "DESCRIPTION"
        }
    }
    
    
    /* helper function to help the screen move up and down when the keyboard shows or dismisses */
    func animateViewMoving(up: Bool) {
        var movement = (up ? -keyboardHeight : keyboardHeight)
        
        UIView.animateWithDuration(0.5, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardHeight = keyboardSize.height
                self.animateViewMoving(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        animateViewMoving(false)
    }
    
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func btnClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion:nil)
    }
}

