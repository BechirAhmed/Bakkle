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
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        println("User Email: \(userEmail)")
        
        let mainWebView : MainWebView = MainWebView()
        self.performSegueWithIdentifier(mainScreenSegueIdentifier, sender: self)
        
//        let mainScreenViewController : FeedScreen = FeedScreen()
//        self.performSegueWithIdentifier(mainScreenSegueIdentifier, sender: self)
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

