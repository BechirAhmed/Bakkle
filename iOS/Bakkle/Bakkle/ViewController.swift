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
    
    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var fbLoginViewBtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       // fbLoginView.center = self.view.center
    //    self.view.addSubview(fbLoginView)
        

        fbLoginView.frame = fbLoginViewBtn.frame;
        //fbLoginView.frame = CGRectOffset(fbLoginView.frame, 65, 526)
        
        self.view.addSubview(fbLoginView)
        //fbLoginView.sizeToFit()
        
        fbLoginView.frame.origin = CGPointMake(200, 400)
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "publish_actions"]

        
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        var userEmail = user.objectForKey("email") as String
        var userGender = user.objectForKey("gender") as String
        var userUsername = user.objectForKey("username") as String!
        
        let debug = false
        let switchWebNative = true
        
        var postString = ""
        
        postString += "email=\(userEmail)&Name=\(user.name)&UserName=\(userUsername)&Gender=\(userGender)&UserID=\(user.objectID)&locale=\(user.location)&FirstName=\(user.first_name)&LastName=\(user.last_name)"
        
        let url:NSURL? = NSURL(string: "https://app.bakkle.com/account/facebook")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)

            println("Post STRING IS: \(postString)")
        }
        task.resume()
        
        if(debug) {
            println("User: \(user)")
            println("User ID: \(user.objectID)")
            println("User Name: \(user.name)")
            var userEmail = user.objectForKey("email") as String
            println("User Email: \(userEmail)")
        }
        
        
        // Sucessfully logged in via FB
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate!
        appDelegate.registerForPushNotifications(UIApplication.sharedApplication(), userid: user.objectID)
        
        
        
        // SWITCH BETWEEN NATIVE OR WEB CODE
        if(switchWebNative) {
            let mainWebView : MainWebView = MainWebView()
            self.performSegueWithIdentifier(mainScreenSegueIdentifier, sender: self)
        } else {
            let mainScreenViewController : FeedScreen = FeedScreen()
            self.performSegueWithIdentifier(mainScreenSegueIdentifier, sender: self)
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

