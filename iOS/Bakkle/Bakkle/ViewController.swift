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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       // fbLoginView.center = self.view.center
    //    self.view.addSubview(fbLoginView)
        
        fbLoginView.frame = CGRectOffset(fbLoginView.frame, 65, 526)
        
        self.view.addSubview(fbLoginView)
        fbLoginView.sizeToFit()
        
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
        
        let mainScreenViewController : FeedScreen = FeedScreen()
        self.performSegueWithIdentifier(mainScreenSegueIdentifier, sender: self)
      //  self.navigationController?.pushViewController(mainScreenViewController, animated: true)
     //   self.presentViewController(mainScreenViewController, animated: true, completion: nil)
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

