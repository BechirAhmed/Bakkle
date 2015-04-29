//
//  Settings.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class SettingsView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBAction func btnDemo(sender: AnyObject) {
        let alertController = UIAlertController(title: "Bakkle", message:
            "This feature not active for DEMO.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        println("facebook_id: \(Bakkle.sharedInstance.facebook_id_str)")
        var facebookProfileImageUrlString = "http://graph.facebook.com/\(Bakkle.sharedInstance.facebook_id_str)/picture?type=large"
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                let imgURL = NSURL(string: facebookProfileImageUrlString)
                if let imgData = NSData(contentsOfURL: imgURL!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        println("[SettingsView] displaying image \(facebookProfileImageUrlString)")
                        self.avatar.image = UIImage(data: imgData)
                    }
                }
        }
        
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
}

