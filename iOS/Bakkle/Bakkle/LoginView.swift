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
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoImageViewAspectRatio: NSLayoutConstraint!
    
    
    var background:UIImageView!
    var logo: UIImageView!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.image = UIImage(named: "Goodwill Logo-White.png")!
        logo.image = UIImage(named: "Goodwill Logo-White.png")!
        
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "publish_actions"]
        
        // add the image, making the login view looks like the launch screen when user already logged in
        setBackgroundImg()
//        setLogoImg()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // clear the counter every time the login view shows
        counter = 0
        
        // check if the user already logged in, if not, set the background image to transparent
        if FBSession.activeSession().accessTokenData != nil {
            background.hidden = false
            view.userInteractionEnabled = false
        }else{
            background.hidden = true
            view.userInteractionEnabled = true
        }
    }
    
    // create the background image, which is the same as the launch screen background
    func setBackgroundImg(){
        background = UIImageView(image: UIImage(named: "SplashScreen-bkg.png"))
        background.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.view.addSubview(background)
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
        
        // send the user information to Bakkle server
        Bakkle.sharedInstance.facebook(email, gender: gender, username: username,
            name: name, userid: userid, locale: locale,
            first_name: first_name, last_name: last_name, success:
            {
                // Sucessfully logged in via FB
                Bakkle.sharedInstance.login({
                    
                    // jump into the feedview if successfully logged in
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

