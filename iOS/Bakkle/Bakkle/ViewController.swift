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
    
    let deviceUUID = UIDevice.currentDevice().identifierForVendor.UUIDString
    
    var account_id: String!
 

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
        println("User Logged In")
        
    }
    
    
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        var userEmail = user.objectForKey("email") as String
        var userGender = user.objectForKey("gender") as String
        var userUsername = user.objectForKey("username") as String!
        
        let switchWebNative = true
        
        var postString = ""
        
        postString += "email=\(userEmail)&Name=\(user.name)&UserName=\(userUsername)&Gender=\(userGender)&UserID=\(user.objectID)&locale=\(user.location)&FirstName=\(user.first_name)&LastName=\(user.last_name)&deviceUUID=\(deviceUUID)"
        
        let url:NSURL? = NSURL(string: "https://app.bakkle.com/account/facebook/")
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
            var error: NSError? = error
            
            var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as NSDictionary
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                
            self.account_id = response.valueForKey("userid") as String

            }
            println("Post STRING IS: \(postString)")
            println("RESPONSE STRING IS: \(responseString)")
            println("ACCOUNT ID IS: \(self.account_id)")
        }
        task.resume()
        
        
        // Sucessfully logged in via FB
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate!
        appDelegate.registerForPushNotifications(UIApplication.sharedApplication(), userid: user.objectID, deviceuuid: self.deviceUUID, account_id: self.account_id)
        
        
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
    
}

