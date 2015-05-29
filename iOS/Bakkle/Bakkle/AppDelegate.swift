//
//  AppDelegate.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/12/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        /* Init Facebook module */
        FBLoginView.self
        FBProfilePictureView.self
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        
//        // in this example, the URL from which the user came is http://example.com/profile/?12345
//        // determine if the user was viewing a profile
//        if ([[url path] isEqualToString:@"/profile"]) {
//            // switch to profile view controller
//            [self.tabBarController setSelectedViewController:profileViewController];
//            // pull the profile id number found in the query string
//            NSString *profileID = [url query];
//            // pass profileID to profile view controller
//            [profileViewController loadProfile:profileID];
        
        return wasHandled
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
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBAppEvents.activateApp();
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
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {

        if application.applicationState == UIApplicationState.Active {
            var localNotification: UILocalNotification = UILocalNotification()
            localNotification.userInfo = userInfo
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.fireDate = NSDate()

//            application.applicationIconBadgeNumber = 0 //TODO: Set to unread message count.
            let blob: Dictionary = userInfo as Dictionary
            
            if let aps = userInfo["aps"] as? NSDictionary {
                println("There is an aps")
                if let message = aps["alert"] as? String {
                    println("Message received: \(message)")
                    localNotification.alertBody = message
                }
            }

            if let custom = userInfo["custom"] as? NSDictionary {
                println("There is a custom")
            }
            
            application.scheduleLocalNotification(localNotification)
            
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification" message:[NSString stringWithFormat:@"Your App name received this notification while it was running:\n%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
    }
    
    func application(application: UIApplication!, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]!, reply: (([NSObject : AnyObject]!) -> Void)!) {
        println("I WAS CALLED")
        var dictionary = userInfo as NSDictionary
        var dict: NSDictionary = NSDictionary()
        dict.setValue(UIImage(named: "tiger.jpg"), forKey: "image")
        //dict.setValue("yes", forkey: "success")
        
        if let type = dictionary.objectForKey("type") as? String
        {
            if type == "fetch"
            {
                reply(dict as [NSObject : AnyObject])
            }
        }
    }

}

