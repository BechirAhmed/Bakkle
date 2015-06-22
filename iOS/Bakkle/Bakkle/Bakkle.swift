//
//  Bakkle.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/8/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import Foundation

class Bakkle : NSObject, CLLocationManagerDelegate {
    
    let apiVersion: Float = 1.2
    var url_base: String          = "https://app.bakkle.com/"
    let url_login: String         = "account/login_facebook/"
    let url_logout: String        = "account/logout/"
    let url_facebook: String      = "account/facebook/"
    let url_register_push: String = "account/device/register_push/"
    let url_reset: String         = "items/reset/"
    let url_mark: String          = "items/" //+status/
    let url_feed: String          = "items/feed/"
    let url_garage: String        = "items/get_seller_items/"
    let url_add_item: String      = "items/add_item/"
    let url_send_chat: String     = "conversation/send_message/"
    let url_view_item: String     = "items/"
    let url_buyers_trunk: String        = "items/get_buyers_trunk/"
    let url_get_holding_pattern: String = "items/get_holding_pattern/"
    let url_buyertransactions: String   = "items/get_buyer_transactions/"
    let url_sellertransactions: String  = "items/get_seller_transactions/"

    static let bkFeedUpdate    = "com.bakkle.feedUpdate"
    static let bkGarageUpdate  = "com.bakkle.garageUpdate"
    static let bkTrunkUpdate   = "com.bakkle.trunkUpdate"
    static let bkHoldingUpdate = "com.bakkle.holdingUpdate"
    static let bkFilterChanged = "com.bakkle.filterChanged"
    
    /* 1 - ERROR
     * 2 - INFO
     * 3 - DEBUG
     */
    var debug: Int = 2 // 0=off
    var serverNum: Int = 0
    var deviceUUID : String = UIDevice.currentDevice().identifierForVendor.UUIDString
    
//    var account_id: Int! = 0
    var auth_token: String!
    var display_name: String!
    var email: String!
    var facebook_id: Int!
    var facebook_id_str: String!
    var first_name: String!
    var last_name: String!
    
    var feedItems: [NSObject]!
    var garageItems: [NSObject]!
    var trunkItems: [NSObject]!
    var holdingItems: [NSObject]!
    
    //TODO: Remove
    var responseDict: NSDictionary!
    
    var filter_distance: Float = 100
    var filter_price: Float = 50
    var filter_number: Float = 80
    
    var search_text: String = ""
    var user_location: String = ""
    var user_loc: CLLocation?
    
    class var sharedInstance: Bakkle {
        struct Static {
            static let instance: Bakkle = Bakkle()
        }
        return Static.instance
    }

    override init() {
        super.init()
        info("API initialized \(apiVersion)");

        // Switch servers
        setServer()
        info("Using server: \(self.serverNum) \(self.url_base)")

        self.getFilter()
        self.restoreData()
        self.initLocation()
    }
    
    /* Return a public URL to the item on the web */
    /* In future we hope to have a URL shortener */
    func getImageURL( item_id: Int ) -> ( String ) {
        return url_base + url_view_item + "\(item_id)/"
    }
    
    /* Location */
    let locationManager: CLLocationManager = CLLocationManager()
    func initLocation() {
        // Request permission
        locationManager.requestWhenInUseAuthorization()
        
        // load last location (or set default)
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let f = userDefaults.objectForKey("user_location") as? NSString {
            self.user_location = f as String
            self.user_loc = CLLocation(locationString: self.user_location)
            self.info("Restored user's last location: \(self.user_location)")
        } else {
            // Phony "default" location
            self.user_loc = CLLocation(latitude: 39.417672, longitude: -87.330438)
            self.user_location = "39.417672,-87.330438"
            self.info("Set phony default location: \(self.user_location)")
        }

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                locationManager.startMonitoringSignificantLocationChanges()
            }
            
            // Quirk to support simulating location in simulator
//            if UIDevice.currentDevice().model == "iPhone Simulator" {
                locationManager.startUpdatingLocation()
  //          }
        } else {
            // TODO : Warn no location services available
        }
    }
    // Returns miles
    func distanceTo(destination: CLLocation) -> (CLLocationDistance?) {
        if destination.coordinate.latitude == 0 {
            return .None
        }
        if let start = user_loc {
            println( destination.toString() )
            println( user_loc!.toString())
            println( destination.distanceFromLocation(start))
            return destination.distanceFromLocation(start) / 1609.34
        } else {
            return .None
        }
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if locations[0].latitude == nil {
            return
        }
        self.user_loc = locations[0] as? CLLocation
        self.user_location = "\( locations[0].latitude ), \( locations[0].longitude )"
        self.debg("Received new location: \(self.user_location)")
    }
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if newLocation == nil {
            return
        }
        self.user_loc = newLocation
        self.user_location = "\( newLocation.coordinate.latitude ), \( newLocation.coordinate.longitude )"
        self.debg("Received new location: \(self.user_location)")
        
        // Store location
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(self.user_location, forKey: "user_location")
        userDefaults.synchronize()
    }
    /* End location */
    
    func setServer() {
        serverNum = NSUserDefaults.standardUserDefaults().integerForKey("server")
        switch( serverNum )
        {
            case 0: self.url_base = "https://app.bakkle.com/"
            //case 0: self.url_base = "https://PRODCLUSTER-16628191.us-west-2.elb.amazonaws.com/"
            case 1: self.url_base = "https://app-cluster.bakkle.com/"
            case 2: self.url_base = "http://bakkle.rhventures.org:8000/"
            case 3: self.url_base = "http://wongb.rhventures.org:8000/"
            case 4: self.url_base = "http://10.0.0.118:8000/"
            //case 4: self.url_base = "http://137.112.57.140:8000/"
            case 5: self.url_base = "" //Patrick
            case 6: self.url_base = "" //Xinyu
            case 7: self.url_base = "" //Joe
            default: self.url_base = "https://app.bakkle.com/"
        }
    }

    func refresh() {
        /* TODO: this will request a data update from the server */
        self.populateFeed({})
        //TODO: update others too
    }
    
    func appVersion() -> (build: String, bundle: String) {
        let build: String = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as! String
        let bundleName: String = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as! String
        let shortVersion: String = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
        
        return (build,bundleName)
    }
    
    /* register and login using facebook */
    func facebook(email: String, gender: String, username: String,
        name: String, userid: String, locale: String, first_name: String, last_name: String, success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_facebook)
        let request = NSMutableURLRequest(URL: url!)
        
        self.facebook_id_str = userid
        self.facebook_id = userid.toInt()
            
        request.HTTPMethod = "POST"
        let postString = "email=\(email)&name=\(name)&user_name=\(username)&gender=\(gender)&user_id=\(userid)&locale=\(locale)&first_name=\(first_name)&last_name=\(last_name)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("facebook")
        info("URL: \(url)")
        info("METHOD: \(request.HTTPMethod)")
        info("BODY: \(postString)")
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
            if (data != nil && data.length != 0) {
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.display_name = username
                    self.email = email
                    self.first_name = first_name
                    self.last_name = last_name
                    success()
                }
            } else {
                //TODO: Trigger reattempt to connect timer.
            }
        }
        task.resume()
    }
    
    /* login and get account details */
    func login(success: ()->(), fail: ()->()) {
            let url:NSURL? = NSURL(string: url_base + url_login)
            let request = NSMutableURLRequest(URL: url!)
        
            // Get device capabilities
            var bounds: CGRect = UIScreen.mainScreen().bounds
            var screen_width:CGFloat = bounds.size.width
            var screen_height:CGFloat = bounds.size.height
        
            let (a,b) = self.appVersion()
            let encLocation = user_location.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
            request.HTTPMethod = "POST"
            let postString = "device_uuid=\(self.deviceUUID)&user_id=\(self.facebook_id_str)&screen_width=\(screen_width)&screen_height=\(screen_height)&app_version=\(a)&app_build=\(b)&user_location=\(encLocation)&is_ios=true"
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
                println("ResponseLogin: \(responseString)")
                
                /* JSON parse */
                var error: NSError? = error
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary!
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.auth_token = responseDict.valueForKey("auth_token") as! String
                    
                    // Connect to web socket
                    WSManager.setAuthenticationWithUUID(self.deviceUUID, withToken: self.auth_token)
                    WSManager.setAutoRegister(true)
                    WSManager.connectWS()
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
            
            self.auth_token = ""
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
            self.debg("Response: \(responseString)")
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
                self.debg("Response: \(responseString)")
                
                //TODO: Check error handling here.
//                var err: NSError?
//                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err) as NSDictionary!
//                
                //TODO: THIS IS WRONG
                //if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.persistData()
                
                switch(status){
                case "meh":
                    break
                case "want":
                    NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkGarageUpdate, object: self)
                    break
                case "hold":
                    NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkHoldingUpdate, object: self)
                    break
                case "report":
                    break
                default:
                    break;
                    
                }
                    success()
              //  }

            }
            fail()
        }
        task.resume()
        }
    }
    
    /* Populates the garage with items from the server */
    func populateGarage(success: ()->()) {
        let url: NSURL? = NSURL(string: url_base + url_garage)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] populateGarage")
        info("[Bakkle]  URL: \(url)")
        info("[Bakkle]  METHOD: \(request.HTTPMethod)")
        info("[Bakkle]  BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            //self.debg("Response: \(responseString)")
            
            var parseError: NSError?
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
            self.info("RESPONSE DICT IS: \(self.responseDict)")
            
            if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                self.garageItems = self.responseDict.valueForKey("seller_garage") as! Array
                self.persistData()
                NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkGarageUpdate, object: self)
                success()
            }
        }
        task.resume()
    }
    
    /* Populates the holding pattern with items from the server */
    func populateHolding(success: ()->()) {
        let url: NSURL? = NSURL(string: url_base + url_get_holding_pattern)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] populateHolding")
        info("[Bakkle]  URL: \(url)")
        info("[Bakkle]  METHOD: \(request.HTTPMethod)")
        info("[Bakkle]  BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            self.info("Response: \(responseString)")
            
            var parseError: NSError?
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
            self.debg("RESPONSE DICT IS: \(self.responseDict)")
            
            if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                self.holdingItems = self.responseDict.valueForKey("holding_pattern") as! Array
                self.persistData()
                NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkHoldingUpdate, object: self)
                success()
            }
        }
        task.resume()
    }

    /* Populates the trunk with items from the server */
    func populateTrunk(success: ()->()) {
        let url: NSURL? = NSURL(string: url_base + url_buyers_trunk)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] populateTrunk")
        info("[Bakkle]  URL: \(url)")
        info("[Bakkle]  METHOD: \(request.HTTPMethod)")
        info("[Bakkle]  BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            self.info("Response: \(responseString)")
            
            var parseError: NSError?
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
            self.debg("RESPONSE DICT IS: \(self.responseDict)")
            
            if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                self.trunkItems = self.responseDict.valueForKey("buyers_trunk") as! Array
                // cheap hack to get data for testing
                //self.trunkItems = self.feedItems
                self.persistData()
                NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkTrunkUpdate, object: self)
                success()
            }
            
        }
        task.resume()
    }
    
    /* Populates the feed with items from the server */
    func populateFeed(success: ()->()) {
        let url: NSURL? = NSURL(string: url_base + url_feed)
        let request = NSMutableURLRequest(URL: url!)
        
        let encLocation = user_location.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&search_text=\(self.search_text)&filter_distance=\(Int(self.filter_distance))&filter_price=\(Int(self.filter_price))&filter_number=\(Int(self.filter_number))&user_location=\(encLocation)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] populateFeed")
        info("[Bakkle]  URL: \(url)")
        info("[Bakkle]  METHOD: \(request.HTTPMethod)")
        info("[Bakkle]  BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }

            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            //self.debg("Response: \(responseString)")
            
            var parseError: NSError?
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
            self.info("RESPONSE DICT IS: \(self.responseDict)")
            
            if self.responseDict != nil {
                if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                    if let feedEl: AnyObject = self.responseDict["feed"] {
                        //TODO: only update new items.
                        self.feedItems = self.responseDict.valueForKey("feed") as! Array
                        self.persistData()
                        NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFeedUpdate, object: self)
                    }
                    //note called on success, not 'new items'
                    self.prepareTopFeedItemsForWatch()
                    
                    /* temp phone hack */
//                    var groupURL: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.bakklefeed")!;
//                    var shareURL: NSURL = groupURL.URLByAppendingPathComponent("item.png")
//                    //312 x 390
//                    var size = CGSizeMake(312, 312)
//                    var scaledImage: UIImage = UIImage(named: "tiger.jpg")!
//                    scaledImage.resize(size, completionHandler: { (resizedImage, data) -> () in
//                        UIImagePNGRepresentation(resizedImage).writeToURL(shareURL, atomically: true)
//                    })
                    /* end hack */
                    
                    
                    success()
                }
            }
        }
        task.resume()
    }
    
    func prepareTopFeedItemsForWatch(){
        /*for item in Bakkle.sharedInstance.feedItems{
            let imgURLs = item.valueForKey("image_urls") as! NSArray
            let imgURL = imgURLs[0] as! String
            let fancyImgURL = NSURL(string: imgURL)
            let data = NSData(contentsOfURL: fancyImgURL!)
            let filename = fancyImgURL?.lastPathComponent
            
            var groupURL: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.bakklefeed")!;
            var shareURL: NSURL = groupURL.URLByAppendingPathComponent(filename!)
            //312 x 390
            var size = CGSizeMake(312, 312)
            var scaledImage: UIImage = UIImage(data: data!)!
            scaledImage.resize(size, completionHandler: { (resizedImage, data) -> () in
                UIImagePNGRepresentation(resizedImage).writeToURL(shareURL, atomically: true)
            })
        }*/
    }
    
    //http://localhost:8000/conversation/send_message/?auth_token=asdfasdfasdfasdf_1&message=I'd like 50 for it.&device_uuid=E6264D84-C395-4132-8C63-3EF051480191&conversation_id=7
    func sendChat(conversation_id: Int, message: String, success: ()->(), fail: ()->() ) {
        // URL encode some vars.
        let escMessage = message.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let postString = "device_uuid=\(self.deviceUUID)&auth_token=\(self.auth_token)&message=\(escMessage)&conversation_id=\(conversation_id)"
        let url: NSURL? = NSURL(string: url_base + url_send_chat + "?\(postString)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] sendChat")
        info("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            self.debg("Response: \(responseString)")
            
            var parseError: NSError?
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
            self.debg("RESPONSE DICT IS: \(self.responseDict)")
            if (data != nil && data.length != 0 ) {
                
//            }&& Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 ){
    //                let item_id: Int = self.responseDict.valueForKey("item_id") as! Int
    //                let item_url: String = self.getImageURL(item_id)
                    success()
            } else {
                fail()
            }
        }
        task.resume()
    }
    func onNewChat(conversation_id: Int, message: String, timestamp: time_t) {
        
    }
    
    func addItem(title: String, description: String, location: String, price: String, tags: String, method: String, images: [UIImage], success: (item_id: Int?, item_url: String?)->(), fail: ()->() ) {
        
        // URL encode some vars.
        let escTitle = title.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let escDescription = description.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let escLocation = location.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let escTags = tags.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let escMethod = method.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var escPrice: String!
        if price == "take it!" {
            escPrice = "0.00"
        } else {
            escPrice = price.stringByReplacingOccurrencesOfString("$ ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        let postString = "device_uuid=\(self.deviceUUID)&title=\(escTitle)&description=\(escDescription)&location=\(escLocation)&auth_token=\(self.auth_token)&price=\(escPrice)&tags=\(escTags)&method=\(escMethod)"
        let url: NSURL? = NSURL(string: url_base + url_add_item + "?\(postString)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        var imageData: [NSData] = [NSData]();
        
        for i in images{
            imageData.append(UIImageJPEGRepresentation(i, 0.5))
        }
        
        var imageDataLength = 0;
        for i in imageData{
            imageDataLength += i.length;
        }
        
        let postLength: String = "\(imageDataLength)"
        
        
        var boundary:String = "---------------------------14737809831466499882746641449"
        var contentType:String = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var body:NSMutableData = NSMutableData()
                
        //add all images as neccessary.
        for i in imageData{
            body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData(i)
            body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        }
        request.HTTPBody = body
        
        info("[Bakkle] addItem")
        info("URL: \(url) METHOD: \(request.HTTPMethod) BODY: --binary blob-- LENGTH: \(imageDataLength)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                self.err("error= \(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            self.debg("Response: \(responseString)")
            println("Response: \(responseString)")
            
            var parseError: NSError?
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary!
            self.debg("RESPONSE DICT IS: \(self.responseDict)")
            
            if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                let item_id: Int = self.responseDict.valueForKey("item_id") as! Int
                let item_url: String = self.getImageURL(item_id)
                success(item_id: item_id, item_url: item_url)
            } else {
                fail()
            }
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
                self.err("error= \(error)")
                return
            }
            
            if let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                self.debg("Response: \(responseString)")
                
                // TODO: Refresh UI
                success()
            }
        }
        task.resume()
    }

    func getFilter() {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

        if let x = userDefaults.objectForKey("filter_distance") as? Float {
            self.filter_distance = x
            self.debg("Restored filter_distance = \(x)")
        } else {
            self.filter_distance = 50
        }
        if let y = userDefaults.objectForKey("filter_price")    as? Float {
            self.filter_price = y
            println("Restored filter_price = \(y)")
        } else {
            self.filter_price = 50
        }
        if let z = userDefaults.objectForKey("filter_number")   as? Float {
            self.filter_number = z
            println("Restored filter_number = \(z)")
        }else{
            self.filter_number = 100
        }
        NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFilterChanged, object: self)
    }
    func setFilter(ffilter_distance: Float, ffilter_price: Float, ffilter_number:Float) {
        self.filter_distance = ffilter_distance
        self.filter_price = ffilter_price
        self.filter_number = ffilter_number
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(self.filter_distance, forKey: "filter_distance")
        userDefaults.setFloat(self.filter_price,    forKey: "filter_price")
        userDefaults.setFloat(self.filter_number,   forKey: "filter_number")
        userDefaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFilterChanged, object: self)
    }
    
    func restoreData() {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        // reset instructional overlay
        if let f = userDefaults.objectForKey("instruction") as? Bool{
            
        }else{
            userDefaults.setBool(true, forKey: "instruction")
        }
        // We force a version upgrade
        if let version = userDefaults.objectForKey("version") as? NSString {
            info("Stored version: \(version)")
            info("Current version: \(self.appVersion().build)")
            if version != self.appVersion().build {
                userDefaults.setBool(true, forKey: "instruction")
            }
            if version == self.appVersion().build {
            
                // restore FEED
                if let f = userDefaults.objectForKey("feedItems") as? NSString {
                    var parseError: NSError?
                    var jsonData: NSData = f.dataUsingEncoding(NSUTF8StringEncoding)!
                    self.feedItems = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! Array
                    self.info("Restored \( (self.feedItems as Array).count) feed items.")
                    NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFeedUpdate, object: self)
                }
                
                // restore GARAGE
                if let f = userDefaults.objectForKey("garageItems") as? NSString {
                    var parseError: NSError?
                    var jsonData: NSData = f.dataUsingEncoding(NSUTF8StringEncoding)!
                    self.garageItems = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! Array
                    self.info("Restored \( (self.garageItems as Array).count) garage items.")
                    NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkGarageUpdate, object: self)
                }

                // restore HOLDING
                if let f = userDefaults.objectForKey("holdingItems") as? NSString {
                    var parseError: NSError?
                    var jsonData: NSData = f.dataUsingEncoding(NSUTF8StringEncoding)!
                    self.holdingItems = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! Array
                    self.info("Restored \( (self.holdingItems as Array).count) holding items.")
                    NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkHoldingUpdate, object: self)
                }

                return
                
            }
        }
        
        // ELSE: Purge old version data
        
    }
    func persistData() {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        // Store FEED
        if self.feedItems != nil {
            let data = NSJSONSerialization.dataWithJSONObject(self.feedItems, options: nil, error: nil)
            let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
            userDefaults.setObject(string,   forKey: "feedItems")
            self.info("Stored \( (self.feedItems as Array).count) feed items")
        } else {
            userDefaults.removeObjectForKey("feedItems")
        }
        
        // Store GARAGE
        if self.garageItems != nil {
            let data2 = NSJSONSerialization.dataWithJSONObject(self.garageItems, options: nil, error: nil)
            let string2 = NSString(data: data2!, encoding: NSUTF8StringEncoding)
            userDefaults.setObject(string2,   forKey: "garageItems")
            self.info("Stored \( (self.garageItems as Array).count) garage items")
        } else {
            userDefaults.removeObjectForKey("garageItems")
        }

        // Store HODLING
        if self.holdingItems != nil {
            let data3 = NSJSONSerialization.dataWithJSONObject(self.holdingItems, options: nil, error: nil)
            let string3 = NSString(data: data3!, encoding: NSUTF8StringEncoding)
            userDefaults.setObject(string3,   forKey: "holdingItems")
            self.info("Stored \( (self.holdingItems as Array).count) holding items")
        } else {
            userDefaults.removeObjectForKey("holdingItems")
        }

        // Store VERSION
        userDefaults.setObject(self.appVersion().build, forKey: "version")
        self.info("Stored version = \(self.appVersion().build)")
        
        userDefaults.synchronize()
    }
    
    func err(logMessage: String, functionName: String = __FUNCTION__, line: Int = __LINE__, file: String = __FILE__) {
        if self.debug>=1 {
            println("[ERRR] \(file.lastPathComponent.stringByDeletingPathExtension):(\(line)): \(logMessage)")
        }
    }
    
    func info(logMessage: String, functionName: String = __FUNCTION__, line: Int = __LINE__, file: String = __FILE__) {
        var prettyFunc = functionName
//        var range = functionName.rangeOfString("(")
//        
//        if let r = range {
//        //the correct solution
//            var intIndex: Int = distance(functionName.startIndex, range!.startIndex)
//            var startIndex2 = advance(functionName.startIndex, intIndex)
//            var range2 = startIndex2...startIndex2
//            
//            prettyFunc = functionName[range2]
//        }
        if self.debug>=2 {
            println("[INFO] \(file.lastPathComponent.stringByDeletingPathExtension):\(prettyFunc)(\(line)): \(logMessage)")
        }
    }
    
    func debg(logMessage: String, functionName: String = __FUNCTION__, line: Int = __LINE__, file: String = __FILE__) {
        if self.debug>=3 {
            println("[DEBG] \(file.lastPathComponent.stringByDeletingPathExtension):(\(line)): \(logMessage)")
        }
    }
    
    
    // HELPERS
    
}