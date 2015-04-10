//
//  ViewController.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/12/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBLoginViewDelegate {

    let mainScreenSegueIdentifier = "PushToFeedSegue"
    
    let isNative = true
 

    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var fbLoginViewBtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLoginView.frame = fbLoginViewBtn.frame;
        
        self.view.addSubview(fbLoginView)
        
        fbLoginView.frame.origin = CGPointMake(200, 400)
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "publish_actions"]
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged in")
    }
    
    
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
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
                
            // Register for push notifications.
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
            appDelegate.registerForPushNotifications(UIApplication.sharedApplication())
        
            
            // SWITCH BETWEEN NATIVE OR WEB CODE
            if(self.isNative) {
                let feedVC : FeedScreen = FeedScreen()
                self.performSegueWithIdentifier(self.mainScreenSegueIdentifier, sender: self)
               
            } else {
                let mainWebView : MainWebView = MainWebView()
                self.performSegueWithIdentifier(self.mainScreenSegueIdentifier, sender: self)
            }
        })
        
        //TODO: Display error on fail?
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
}

