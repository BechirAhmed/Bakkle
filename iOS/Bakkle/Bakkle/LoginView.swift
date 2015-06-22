//
//  ViewController.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/12/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class LoginView: UIViewController, FBLoginViewDelegate {
    
    let mainScreenSegueIdentifier = "PushToFeedSegue"
    
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    var background:UIImageView!
    var logo: UIImageView!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "publish_actions"]
        
        background = UIImageView(image: UIImage(named: "SplashScreen-bkg.png"))
        background.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.view.addSubview(background)
        logo = UIImageView(image: UIImage(named: "logo-white-design-png-100.png"))
        background.addSubview(logo)
        
        logo.setTranslatesAutoresizingMaskIntoConstraints(false)
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 102.0))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        counter = 0
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.boolForKey("login") {
            background.hidden = false
            logo.hidden = false
        }else{
            Bakkle.sharedInstance.logout()
            FBSession.activeSession().closeAndClearTokenInformation()
            background.hidden = true
            logo.hidden = true
        }
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        // tricky way to force the function only run once when it called twice
        if counter > 0 {
            return
        }
        counter++;
        
        var email = user.objectForKey("email") as! String!
        var gender = user.objectForKey("gender") as! String!
        var username = "" //user.objectForKey("username") as String!
        var name = user.name
        var userid = user.objectID
        var locale = "nil" //user.location.location.zip //ZIP for now
        var first_name = user.first_name
        var last_name = user.last_name
        
        Bakkle.sharedInstance.facebook(email, gender: gender, username: username,
            name: name, userid: userid, locale: locale,
            first_name: first_name, last_name: last_name, success:
            {
                // Sucessfully logged in via FB
                Bakkle.sharedInstance.login({
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier(self.mainScreenSegueIdentifier, sender: self)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Register for push notifications.
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
                        appDelegate.registerForPushNotifications(UIApplication.sharedApplication())
                    }
                    
                    }, fail: {})
        })
        
        //TODO: Display error on fail?
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        // Do nothing. Automatically segues back to login view.
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
}

