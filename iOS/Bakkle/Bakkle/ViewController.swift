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
        
        var userInfo : String = "\(user)"    //= "UserID: \(user.objectID) & UserName: \(user.name) & UserEmail: \(userEmail)"
        
        let url:NSURL? = NSURL(string: "https://app.bakkle.com/notifications/account/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "device_token=\(userInfo)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
           //  println("response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
           // println("responseString = \(responseString)")
        }
        task.resume()
        
        
//        println("User: \(user)")
//        println("User ID: \(user.objectID)")
//        println("User Name: \(user.name)")
//        var userEmail = user.objectForKey("email") as String
//        println("User Email: \(userEmail)")
        
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

