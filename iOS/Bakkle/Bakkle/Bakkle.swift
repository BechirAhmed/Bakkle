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
    let url_base: String          = "https://app.bakkle.com/"
//    let url_base: String          = "http://137.112.63.186:8000/"
    let url_login: String         = "account/login_facebook/"
    let url_logout: String        = "account/logout/"
    let url_facebook: String      = "account/facebook/"
    let url_register_push: String = "account/device/register_push/"
    let url_reset: String         = "items/reset/"
    let url_mark: String          = "items/" //+status/
    let url_feed: String          = "items/feed/"
    
    var debug: Int = 1 // 0=off
    var deviceUUID : String = UIDevice.currentDevice().identifierForVendor.UUIDString
    
    var account_id: Int! = 0
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
            let postString = "email=\(email)&Name=\(name)&UserName=\(username)&Gender=\(gender)&UserID=\(userid)&locale=\(locale)&FirstName=\(first_name)&LastName=\(last_name)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        println("[Bakkle] facebook")
        println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            println("Response: \(data)")

            /* JSON parse */
            var error: NSError? = error
            var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary!
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                self.account_id = responseDict.valueForKey("account_id") as! Int!
                
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
            let postString = "account_id=\(self.account_id)&device_uuid=\(self.deviceUUID)&user_id=\(self.facebook_id)"
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
                    self.account_id = responseDict.valueForKey("account_id") as! Int!
                    self.display_name = responseDict.valueForKey("display_name") as! String!
                    self.email = responseDict.valueForKey("email") as! String!
                    //self.facebook_id = (responseDict.valueForKey("facebook_id") as! String).toInt()
                    success()
                } else {
                    fail()
                }
            }
            task.resume()
    }
    
    /* logout */
    func logout() {
        self.account_id = 0
        
        let url:NSURL? = NSURL(string: url_base + url_logout)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "account_id=\(self.account_id)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        println("Logout account_id:\(account_id) device:\(self.deviceUUID)")
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
        let postString = "account_id=\(self.account_id)&device_uuid=\(self.deviceUUID)&device_token=\(deviceToken)"
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
        
        request.HTTPMethod = "POST"
        let postString = "account_id=\(self.account_id)&device_uuid=\(self.deviceUUID)&item_id=\(item_id)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        println("[Bakkle] markItem")
        println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
//            if error != nil {
//                println("error=\(error)")
//                fail()
//                return
//            }
            
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
        let postString = "account_id=\(Bakkle.sharedInstance.account_id)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] populateFeed")
        info("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }
            let tempStr = "{\"status\": 1, \"feed\": [{\"fields\": {\"status\": \"Active\", \"times_reported\": 0, \"description\": \"Year old orange push mower. Some wear and sun fadding. Was kept outside and not stored in shed.\", \"title\": \"Orange Push Mower\", \"price\": \"50.25\", \"tags\": \"lawnmower, orange, somewear\", \"image_urls\": \"https://app.bakkle.com/img/b83bdbd.png\", \"seller\": 1, \"post_date\": \"2015-04-08T13:50:02.850Z\", \"location\": \"39.417672,-87.330438\", \"method\": \"Pick-up\"}, \"model\": \"items.items\", \"pk\": 10},{\"fields\":{\"status\":\"Active\",\"times_reported\":0,\"description\":\"Homemade lawn mower. Includes rabbit and water container.\",\"title\":\"Rabbit Push Mower\",\"price\":\"10.99\",\"tags\":\"lawnmower, homemade, rabbit\",\"image_urls\":\"https://app.bakkle.com/img/b8348df.jpg\",\"seller\":1,\"post_date\":\"2015-04-09T03:41:40.465Z\",\"location\":\"39.417672,-87.330438\",\"method\":\"Pick-up\"},\"model\":\"items.items\",\"pk\":47},{\"fields\":{\"status\":\"Active\",\"times_reported\":0,\"description\":\"iPhone 6. Has a cracked screen. Besides screen phone is in good condition.\",\"title\":\"iPhone 6 Cracked\",\"price\":\"65.99\",\"tags\":\"iPhone6, cracked, damaged\",\"image_urls\":\"https://app.bakkle.com/img/b8349df.jpg\",\"seller\":1,\"post_date\":\"2015-04-09T03:41:40.473Z\",\"location\":\"39.417672,-87.330438\",\"method\":\"Delivery\"},\"model\":\"items.items\",\"pk\":48}]}"
            
            let tempData = tempStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
            let responseString: String = NSString(data: tempData!, encoding: NSUTF8StringEncoding)! as String
            self.resp("Response: \(responseString)")
            var parseError: NSError?
            
            self.responseDict = NSJSONSerialization.JSONObjectWithData(tempData!, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
             self.resp("RESPONSE DICT IS: \(self.responseDict)")
            
             if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                self.feedItems = self.responseDict.valueForKey("feed") as! Array!
                success()
            }
            
        }
        task.resume()
    }
    
    /* reset feed items on server for DEMO */
    func resetDemo(success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_reset)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "account_id=\(self.account_id)&device_uuid=\(self.deviceUUID)"
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