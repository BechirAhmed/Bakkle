//
//  Bakkle.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/8/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import Foundation

class Bakkle {
    
    let apiVersion: Float = 1.2
    var url_base: String          = "https://app.bakkle.com/"
    let url_login: String         = "account/login_facebook/"
    let url_logout: String        = "account/logout/"
    let url_facebook: String      = "account/facebook/"
    let url_register_push: String = "account/device/register_push/"
    let url_reset: String         = "items/reset/"
    let url_mark: String          = "items/" //+status/
    let url_feed: String          = "items/feed/"
    let url_add_item: String      = "items/add_item/"
    
    var debug: Int = 2 // 0=off
    var serverNum: Int = 0
    var deviceUUID : String = UIDevice.currentDevice().identifierForVendor.UUIDString
    
//    var account_id: Int! = 0
    var auth_token: String!
    var display_name: String!
    var email: String!
    var facebook_id: Int!
    var facebook_id_str: String!
    
    var feedItems: [NSObject]!
    var responseDict: NSDictionary!
    
    class var sharedInstance: Bakkle {
        struct Static {
            static let instance: Bakkle = Bakkle()
        }
        return Static.instance
    }

    init() {
        println("Bakkle API initialized \(apiVersion)");
        serverNum = NSUserDefaults.standardUserDefaults().integerForKey("server")
        setServer()
        println("Using server: \(self.serverNum) \(self.url_base)")
    }
    
    func setServer() {
        switch( serverNum )
        {
        case 0: self.url_base = "https://app.bakkle.com/"
        case 1: self.url_base = "localhost"
        case 2: self.url_base = "http://137.112.63.186:8000/"
        default: self.url_base = "https://app.bakkle.com/"
        }
    }

    func refresh() {
        /* TODO: this will request a data update from the server */
    }
    
    /* register and login using facebook */
    func facebook(email: String, gender: String, username: String,
        name: String, userid: String, locale: String, first_name: String, last_name: String, success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_facebook)
        let request = NSMutableURLRequest(URL: url!)
        
        println("userid: \(userid)")
        self.facebook_id_str = userid
        self.facebook_id = userid.toInt()
            
        request.HTTPMethod = "POST"
            let postString = "email=\(email)&name=\(name)&user_name=\(username)&gender=\(gender)&user_id=\(userid)&locale=\(locale)&first_name=\(first_name)&last_name=\(last_name)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        println("[Bakkle] facebook")
        println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding:NSUTF8StringEncoding)
            println("Response: \(responseString)")
            
            /* JSON parse */
            var error: NSError? = error
            var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary!
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                self.display_name = username
                self.email = email
                success()
            }
        }
        task.resume()
    }
    
    /* login and get account details */
    func login(success: ()->(), fail: ()->()) {
            let url:NSURL? = NSURL(string: url_base + url_login)
            let request = NSMutableURLRequest(URL: url!)
            
            request.HTTPMethod = "POST"
            let postString = "device_uuid=\(self.deviceUUID)&user_id=\(self.facebook_id_str)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
            println("[Bakkle] login (facebook)")
            println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                
                if error != nil {
                    println("error=\(error)")
                    return
                }

                let responseString = NSString(data: data, encoding:NSUTF8StringEncoding)
                println("Response: \(responseString)")
                
                /* JSON parse */
                var error: NSError? = error
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary!
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.auth_token = responseDict.valueForKey("auth_token") as! String!
                    success()
                } else {
                    Bakkle.sharedInstance.logout()
                    FBSession.activeSession().closeAndClearTokenInformation()
                    fail()
                }
            }
            task.resume()
    }
    
    /* logout */
    func logout() {
        self.auth_token = ""
        
        let url:NSURL? = NSURL(string: url_base + url_logout)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        println("Logout auth_token:\(auth_token) device:\(self.deviceUUID)")
        println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Response: \(responseString)")
        }
        task.resume()
    }

    /* register device for push notifications */
    func register_push(deviceToken: NSData) {
        let url:NSURL? = NSURL(string: url_base + url_register_push)
        let request = NSMutableURLRequest(URL: url!)

        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&device_token=\(deviceToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

        println("[Bakkle] register_push")
        println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            self.resp("Response: \(responseString)")
        }
        task.resume()
    }
   
    /* mark feed item 'status' as MEH/WANT/HOLD/REPORT */
    func markItem(status: String, item_id: Int, success: ()->(), fail: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_mark + "\(status)/")
        let request = NSMutableURLRequest(URL: url!)
        
        let view_duration = 42 //TODO: this needs to be accepted as a parm
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&item_id=\(item_id)&view_duration=\(view_duration)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        println("[Bakkle] markItem")
        println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                self.resp("Response: \(responseString)")
                
                //TODO: Check error handling here.
//                var err: NSError?
//                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err) as NSDictionary!
//                
                //TODO: THIS IS WRONG
                //if responseDict.valueForKey("status")?.integerValue == 1 {
                    success()
              //  }

            }
            fail()
        }
        task.resume()
        }
    }
    
    /* Populates the feed with items from the server */
    func populateFeed(success: ()->()) {
        let url: NSURL? = NSURL(string: url_base + url_feed)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] populateFeed")
        info("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }

            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            println("Response: \(responseString)")
            
            var parseError: NSError?
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
             self.resp("RESPONSE DICT IS: \(self.responseDict)")
            
             if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                self.feedItems = self.responseDict.valueForKey("feed") as! Array!
                success()
            }
            
        }
        task.resume()
    }
    
    func addItem(title: String, description: String, location: String, price: String, tags: String, method: String, imageToSend: String) {
        let url: NSURL? = NSURL(string: url_base + url_add_item)
        let request = NSMutableURLRequest(URL: url!)
        let location = "39.417672,-87.330438"
        
        request.HTTPMethod = "POST"
        let postString = "device_uuid=\(self.deviceUUID)&title=\(title)&description=\(description)&location=\(location)&auth_token=\(self.auth_token)&price=\(price)&tags=\(tags)&method=\(method)&image=\(imageToSend)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] addItem")
        info("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            println("Response: \(responseString)")
            var parseError: NSError?
            
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
            self.resp("RESPONSE DICT IS: \(self.responseDict)")            
        }
        task.resume()

    }
    
    /* reset feed items on server for DEMO */
    func resetDemo(success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_reset)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] reset")
        info("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error=\(error)")
                return
            }
            
            if let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                self.resp("Response: \(responseString)")
                
                // TODO: Refresh UI
                success()
            }
        }
        task.resume()
    }
    
    func err(logMessage: String, functionName: String = __FUNCTION__) {
        if self.debug>=1 {
            println("[ERRR] \(functionName): \(logMessage)")
        }
    }
    func info(logMessage: String, functionName: String = __FUNCTION__) {
        if self.debug>=2 {
            println("[INFO] \(functionName): \(logMessage)")
        }
    }
    func resp(logMessage: String, functionName: String = __FUNCTION__) {
        if self.debug>=3 {
            println("[RESP] \(functionName): \(logMessage)")
        }
    }
    
    
    // HELPERS
    
}