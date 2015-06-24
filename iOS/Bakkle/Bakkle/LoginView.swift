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
    var wrongLocationImg: UIImageView!
    var logo: UIImageView!
    var location: CLLocation = CLLocation(latitude: 37.66143, longitude: -121.877703)
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "publish_actions"]
        
        // add the image, making the login view looks like the launch screen when user already logged in
        setBackgroundImg()
        setWrongLocationImg()
        setLogoImg()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // clear the counter every time the login view shows
        counter = 0
        
        // check if the user already logged in, if not, set the background image to transparent
        if FBSession.activeSession().accessTokenData != nil {
            setBackgroundImg(true)
        }else{
            if (Bakkle.sharedInstance.distanceTo(location) > 20 && NSUserDefaults.standardUserDefaults().boolForKey("enableGeofencing")){
                setBackgroundImg(false)
                counter = 1
            }else{
                background.hidden = true
            }
        }
    }
    
    // create the background image, which is the same as the launch screen background
    func setBackgroundImg(){
        background = UIImageView(image: UIImage(named: "SplashScreen-bkg.png"))
        background.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.view.addSubview(background)
    }
    
    func setBackgroundImg(hasImg: Bool){
        background.hidden = false
        if hasImg {
            background.image = UIImage(named: "SplashScreen-bkg.png")
            wrongLocationImg.hidden = true
            logo.hidden = false
        } else{
            background.image = nil
            background.backgroundColor = UIColor(red: 0.0, green: 0.75, blue: 0.30, alpha: 1.0)
            wrongLocationImg.hidden = false
            logo.hidden = true
        }
        
    }
    
    func setWrongLocationImg() {
        wrongLocationImg = UIImageView(image: UIImage(named: "WrongLocationForPhone.png"))
        wrongLocationImg.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.background.addSubview(wrongLocationImg)
    }
    
    // create the logo image, which is the same as the launch screen logo
    func setLogoImg(){
        logo = UIImageView(image: UIImage(named: "logo-white-design-clear.png"))
        background.addSubview(logo)
        
        logo.setTranslatesAutoresizingMaskIntoConstraints(false)
        logo.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: logo, attribute: NSLayoutAttribute.Width, multiplier: 25.0/62.0, constant: 0.0))
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 49.0))
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 36.0))
        background.addConstraint(NSLayoutConstraint(item: logo, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: background, attribute: NSLayoutAttribute.Right, multiplier: 2.0, constant: 36.0))
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

