//
//  AppDelegate.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/12/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import AVFoundation

import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var audioPlayer = AVAudioPlayer()
    
    
    override class func initialize () {
        // Initialize Facebook buttons
        FBSDKLoginButton.initialize()
        FBSDKProfilePictureView.initialize()
        FBSDKSendButton.initialize()
        FBSDKLikeButton.initialize()
        FBSDKShareButton.initialize()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        //        print(Bakkle.sharedInstance.account_type)
        if Bakkle.sharedInstance.account_type == 0 {
            Bakkle.sharedInstance.guestUserID(Bakkle.sharedInstance.deviceUUID){
                Bakkle.sharedInstance.facebook("", name: "Guest User", userid: Bakkle.sharedInstance.guest_id_str, first_name: "Guest", last_name: "User", success: { () -> () in
                    Bakkle.sharedInstance.login({
                        Bakkle.sharedInstance.populateFeed({})
                        }, fail: {})
                    
                    }, fail: {})
            }
        }
        else  {
            print(Bakkle.sharedInstance.first_name)
            Bakkle.sharedInstance.login({ () -> () in
                
                if let options = launchOptions as? [String: AnyObject],
                    notifyPayload: AnyObject = options[UIApplicationLaunchOptionsRemoteNotificationKey] {
                        Bakkle.sharedInstance.userInfo = notifyPayload as! [NSObject : AnyObject]
                        dispatch_async(dispatch_get_main_queue(),{
                            self.helper(notifyPayload as! [NSObject : AnyObject])
                        })
                }
                
                Bakkle.sharedInstance.populateFeed({})
                
                }, fail: {})
        }
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func registerForPushNotifications(application: UIApplication) {
        
        // Register for push notifications
        if application.respondsToSelector("registerUserNotificationSettings:") {
            
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        } else {
            // Register for Push Notifications before iOS 8
            //NOTE: pacify warning application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
        // Alert app that we just came back from sleep
        NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkAppBecameActive, object: nil, userInfo: nil);
        
        Bakkle.sharedInstance.setServer() //Settings may have changed
        //Bakkle.sharedInstance.refresh()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Push Notifications
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        println("Registered for notifications")
        Bakkle.sharedInstance.register_push(deviceToken)
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        println("Failed to register for notifications")
        /* DO nothing on failure */
    }
    
    
    func helper(userInfo: [NSObject : AnyObject]) {
        if let chat_id = (userInfo)["chat_id"] as? Int {
            let vc = self.window?.rootViewController as? UINavigationController
            let item_id = userInfo["item_id"] as? Int
            let seller_id = userInfo["seller_id"] as? Int
            let buyer_id = userInfo["buyer_id"] as? Int
            if seller_id == Bakkle.sharedInstance.account_id {
                // user is a seller
                Bakkle.sharedInstance.getAccount(buyer_id as NSInteger!, success: { (account: NSDictionary) -> () in
                    //   let account = (Bakkle.sharedInstance.responseDict as NSDictionary!).valueForKey("account") as! NSDictionary
                    let name = account.valueForKey("display_name") as! String
                    let buyer = User(facebookID: account.valueForKey("facebook_id") as! String, accountID: buyer_id!, firstName: name, lastName: name)
                    var chatItem: NSDictionary? = nil
                    for index in 0...Bakkle.sharedInstance.garageItems.count-1 {
                        if Bakkle.sharedInstance.garageItems[index].valueForKey("pk") as? Int == item_id {
                            chatItem = Bakkle.sharedInstance.garageItems[index] as? NSDictionary
                        }
                    }
                    let buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chat_id)
                    let chatViewController = ChatViewController(chat: buyerChat)
                    chatViewController.item = chatItem
                    chatViewController.seller = chatItem!.valueForKey("seller") as! NSDictionary
                    chatViewController.isBuyer = false
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        vc!.pushViewController(chatViewController, animated: true)
                    })
                    
                    }, fail: { () -> () in
                })
            }else if buyer_id == Bakkle.sharedInstance.account_id {
                // user is a buyer
                let buyer = User(facebookID: Bakkle.sharedInstance.facebook_id_str,accountID: Bakkle.sharedInstance.account_id,
                    firstName: Bakkle.sharedInstance.first_name, lastName: Bakkle.sharedInstance.last_name)
                var chatItem: NSDictionary? = nil
                for index in 0...Bakkle.sharedInstance.trunkItems.count-1 {
                    if (Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as! NSDictionary).valueForKey("pk") as? Int == item_id {
                        chatItem = Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as? NSDictionary
                    }
                }
                let buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chat_id)
                let chatViewController = ChatViewController(chat: buyerChat)
                chatViewController.item = chatItem
                chatViewController.seller = chatItem!.valueForKey("seller") as! NSDictionary
                chatViewController.isBuyer = true
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    vc!.pushViewController(chatViewController, animated: true)
                })
            }
            
        }
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        if application.applicationState == UIApplicationState.Active {
            var localNotification: UILocalNotification = UILocalNotification()
            localNotification.userInfo = userInfo
            localNotification.fireDate = NSDate()
            
            let blob: Dictionary = userInfo as Dictionary
            if let aps = userInfo["aps"] as? NSDictionary {
                println("There is an aps")
                if let message = aps["alert"] as? String {
                    println("Message received: \(message)")
                    localNotification.alertBody = message
                    localNotification.userInfo = userInfo
                }
            }
            
            application.scheduleLocalNotification(localNotification)
            
            var error:NSError?
            
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            
            let soundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Bakkle_Notification_new", ofType: "m4r")!)
            
            audioPlayer = AVAudioPlayer(contentsOfURL: soundURL, error: &error)
            
            if (error != nil) {
                println("There was an error: \(error)")
            } else {
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
            
        } else if let item_id = userInfo["item_id"] as? Int {
            println("There is a item_id \(item_id)")
            NSNotificationCenter.defaultCenter().postNotificationName("pushNotification", object: nil, userInfo: userInfo)
            
            dispatch_async(dispatch_get_main_queue(),{
                self.helper(userInfo)
            })
        }
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!)
    {
        var dictionary = userInfo! as NSDictionary
        
        if let type = dictionary.objectForKey("type") as? String
        {
            if Bakkle.sharedInstance.feedItems.count == 0 {
                Bakkle.sharedInstance.populateFeed({ () -> () in
                })
            }
            if type == "fetch"
            {
                if Bakkle.sharedInstance.feedItems.count > 0{
                    var topItem = Bakkle.sharedInstance.feedItems[0]
                    let imgURLs = topItem.valueForKey("image_urls") as! NSArray
                    let imgURL = imgURLs[0] as! String
                    let fancyImgURL = NSURL(string: imgURL)
                    let filename = fancyImgURL?.lastPathComponent
                    
                    let topTitle: String = topItem.valueForKey("title") as! String
                    let topPrice: String = topItem.valueForKey("price") as! String
                    let topImage: String = filename!
                    let topItempk = topItem.valueForKey("pk") as? Int
                    let item_id: String = "\(topItempk!)"
                    reply(["success":"yes","item_title":topTitle,"item_price":topPrice,"item_id":item_id, "item_image":topImage])
                } else {
                    reply(["success":"no","item_title":"no item","item_price":"no item","item_id":"no item","item_image":"no item"])
                }
            }else if type == "meh" {
                println("inside meh")
                if let id = dictionary.objectForKey("item_id") as? NSString {
                    Bakkle.sharedInstance.markItem("meh", item_id: id.integerValue, success: { () -> () in
                        }, fail: { () -> () in
                    })
                    // Remove the item that was just marked from the view
                    if Bakkle.sharedInstance.feedItems.count>0 {
                        Bakkle.sharedInstance.feedItems.removeAtIndex(0)
                    }
                    if Bakkle.sharedInstance.feedItems.count > 0{
                        var topItem = Bakkle.sharedInstance.feedItems[0]
                        let imgURLs = topItem.valueForKey("image_urls") as! NSArray
                        let imgURL = imgURLs[0] as! String
                        let fancyImgURL = NSURL(string: imgURL)
                        let filename = fancyImgURL?.lastPathComponent
                        
                        let topTitle: String = topItem.valueForKey("title") as! String
                        let topPrice: String = topItem.valueForKey("price") as! String
                        let topImage: String = filename!
                        let topItempk = topItem.valueForKey("pk") as? Int
                        let item_id: String = "\(topItempk!)"
                        reply(["success":"yes","item_title":topTitle,"item_price":topPrice,"item_id":item_id, "item_image":topImage])
                    } else {
                        reply(["success":"no","item_title":"no item","item_price":"no item","item_id":"no item","item_image":"no item"])
                    }
                }else{
                    reply(["success":"no","item_title":"no item","item_price":"no item","item_id":"no item","item_image":"no item"])
                }
            }else if type == "want" {
                println("inside want")
                if let id = dictionary.objectForKey("item_id") as? NSString {
                    Bakkle.sharedInstance.markItem("want", item_id: id.integerValue, success: { () -> () in
                        }, fail: { () -> () in
                    })
                    // Remove the item that was just marked from the view
                    if Bakkle.sharedInstance.feedItems.count>0 {
                        Bakkle.sharedInstance.feedItems.removeAtIndex(0)
                    }
                    if Bakkle.sharedInstance.feedItems.count > 0{
                        var topItem = Bakkle.sharedInstance.feedItems[0]
                        let imgURLs = topItem.valueForKey("image_urls") as! NSArray
                        let imgURL = imgURLs[0] as! String
                        let fancyImgURL = NSURL(string: imgURL)
                        let filename = fancyImgURL?.lastPathComponent
                        
                        let topTitle: String = topItem.valueForKey("title") as! String
                        let topPrice: String = topItem.valueForKey("price") as! String
                        let topImage: String = filename!
                        let topItempk = topItem.valueForKey("pk") as? Int
                        let item_id: String = "\(topItempk!)"
                        reply(["success":"yes","item_title":topTitle,"item_price":topPrice,"item_id":item_id, "item_image":topImage])
                    } else {
                        reply(["success":"no","item_title":"no item","item_price":"no item","item_id":"no item","item_image":"no item"])
                    }
                }else{
                    reply(["success":"no","item_title":"no item","item_price":"no item","item_id":"no item","item_image":"no item"])
                }
            }else {
                println("Got Some other key")
            }}
    }
}

