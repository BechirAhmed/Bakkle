//
//  Settings.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Haneke

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = user.valueForKey("account") as! NSDictionary
        setupButtons()
        self.backgroundAvatar.contentMode = UIViewContentMode.ScaleAspectFill
        self.backgroundAvatar.clipsToBounds = true
        
        if canEdit {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }else{
            editBtn.hidden = true
            logoutBtn.hidden = true
            titleLabel.text = "PROFILE"
        }
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
    
    override func viewWillAppear(animated: Bool) {
        
        let facebook_id = user.valueForKey("facebook_id") as! String
        println("facebook_id: \(facebook_id)")
        var facebookProfileImageUrlString = "http://graph.facebook.com/\(facebook_id)/picture?width=250&height=250"
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                let imgURL = NSURL(string: facebookProfileImageUrlString)
                dispatch_async(dispatch_get_main_queue()) {
                    println("[SettingsView] displaying image \(facebookProfileImageUrlString)")
                    self.backgroundAvatar.hnk_setImageFromURL(imgURL!)
                    self.avatar.hnk_setImageFromURL(imgURL!)
                    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
                    visualEffectView.frame = self.backgroundAvatar.frame
                    self.backgroundAvatar.addSubview(visualEffectView)
                    
                    self.avatar.layer.cornerRadius = self.avatar.frame.size.width/2
                    self.avatar.layer.borderWidth = 7.0
                    self.avatar.layer.borderColor = UIColor.whiteColor().CGColor
                }
        }
        
        self.nameLabel.text = user.valueForKey("display_name") as? String
        self.descriptionTextView.text = user.valueForKey("description") as? String
        if descriptionTextView.text.isEmpty {
            descriptionTextView.textColor = AddItem.DESCRIPTION_PLACEHOLDER_COLOR
            descriptionTextView.text = "DESCRIPTION"
        }else {
            descriptionTextView.textColor = UIColor.blackColor()
        }
    }
    
    @IBAction func btnLogout(sender: AnyObject) {
        Bakkle.sharedInstance.logout()
        FBSession.activeSession().closeAndClearTokenInformation()
        self.revealViewController().dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        animateViewMoving(true, moveValue: AddItem.KEYBOARD_MOVE_VALUE)
    }

    
    func textViewDidEndEditing(textView: UITextView) {
        animateViewMoving(false, moveValue: AddItem.KEYBOARD_MOVE_VALUE)
    }
    
    /* helper function to help the screen move up and down when the keyboard shows or dismisses */
    func animateViewMoving(up: Bool, moveValue: CGFloat) {
        let movementDuration = 0.5
        let movement = up ? -moveValue : moveValue
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }


    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func btnClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion:nil)
    }
}

