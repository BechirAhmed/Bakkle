//
//  Settings.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Haneke

class SettingsView: UIViewController {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        println("facebook_id: \(Bakkle.sharedInstance.facebook_id_str)")
        var facebookProfileImageUrlString = "http://graph.facebook.com/\(Bakkle.sharedInstance.facebook_id_str)/picture?width=250&height=250"
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                let imgURL = NSURL(string: facebookProfileImageUrlString)
                dispatch_async(dispatch_get_main_queue()) {
                    println("[SettingsView] displaying image \(facebookProfileImageUrlString)")
                    self.avatar.hnk_setImageFromURL(imgURL!)
                    self.avatar.layer.cornerRadius = self.avatar.frame.size.width/2
                }
        }
        
    }
    
    @IBAction func btnLogout(sender: AnyObject) {
        Bakkle.sharedInstance.logout()
        FBSession.activeSession().closeAndClearTokenInformation()
        self.revealViewController().dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
}

