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
    let url_settings: String         = "account/settings/"
    let url_logout: String        = "account/logout/"
    let url_facebook: String      = "account/facebook/"
    let url_register_push: String = "account/device/register_push/"
    let url_reset: String         = "items/reset/"
    let url_mark: String          = "items/" //+status/
    let url_feed: String          = "items/feed/"
    let url_garage: String        = "items/get_seller_items/"
    let url_add_item: String      = "items/add_item/"
    let url_add_item_no_image: String      = "items/add_item_no_image/"
    let url_delete_item: String = "items/delete_item/"
    let url_send_chat: String     = "conversation/send_message/"
    let url_view_item: String     = "items/"
    let url_buyers_trunk: String        = "items/get_buyers_trunk/"
    let url_get_holding_pattern: String = "items/get_holding_pattern/"
    let url_buyertransactions: String   = "items/get_buyer_transactions/"
    let url_sellertransactions: String  = "items/get_seller_transactions/"
    let url_getaccount:String = "account/get_account/"
    let url_setdescription:String = "account/set_description/"

    static let bkFeedUpdate     = "com.bakkle.feedUpdate"
    static let bkGarageUpdate   = "com.bakkle.garageUpdate"
    static let bkTrunkUpdate    = "com.bakkle.trunkUpdate"
    static let bkHoldingUpdate  = "com.bakkle.holdingUpdate"
    static let bkFilterChanged  = "com.bakkle.filterChanged"
    
    // DO NOT ENABLE if there is no way to select servers from settings file.
    static let developerTools   = false
    static let defaultServerNum = 0 // 0 = prod, 1 = prod cluster (sets default server in list below)
    static let servers   =   ["https://app.bakkle.com/",            // 0
                              "https://app-cluster.bakkle.com/",    // 1
                              "http://bakkle.rhventures.org:8000/"] // 2
//                              "http://wongb.rhventures.org:8000/"]  // 3 (Ben)
    static let serverNames = ["Production Server Single",
                              "Production Server Cluster",
                              "Test Server (Developers Only)"]
//                              "Ben (Developers Only)"]
    static let BAKKLE = 1
    static let GOODWILL = 2
    
    /* 1 - ERROR
     * 2 - INFO
     * 3 - DEBUG
     */
    var debug: Int = 2 // 0=off
    var serverNum: Int = 0
    var deviceUUID : String = UIDevice.currentDevice().identifierForVendor.UUIDString
    var flavor: Int = 0
    
    var account_id: Int! = 0
    var auth_token: String!
    var display_name: String!
    var email: String!
    var facebook_id: Int!
    var facebook_id_str: String!
    var first_name: String!
    var last_name: String!
    var profileImgURL: NSURL!
    
    var feedItems: [NSObject]!
    var garageItems: [NSObject]!
    var trunkItems: [NSObject]!
    var holdingItems: [NSObject]!
    
    //TODO: Remove
    var responseDict: NSDictionary!
    
    var filter_distance: Float = 100
    var filter_price: Float = 50
    
    var search_text: String = ""
    var user_location: String = ""
    var user_loc: CLLocation?
    
    var feed_items_to_load : Int = 20
    var image_height : Int = 660
    var image_width : Int = 660
    var image_quality : Float = 0.3
    var image_precache : Int = 10
    
    var theme_base : UIColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 95.0/255.0, alpha: 1.0);
    var theme_baseDark : UIColor = UIColor(red: 41.0/255.0, green: 170.0/255.0, blue: 66.0/255.0, alpha: 1.0);
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
        
        
        /* Set version of app for branding 1=Bakkle, 2=Goodwill */
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String;
        self.flavor = appName == "Bakkle" ? 1 : 2;
        
        if(self.flavor == 2){
            self.theme_base = UIColor(red: 0, green: 83.0/255.0, blue: 160.0/255.0, alpha: 1)
            self.theme_baseDark = UIColor(red: 0, green: 70.0/255.0, blue: 136.0/255.0, alpha: 1)

        }
        
        settings()
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
        if locations[0].coordinate == nil {
            return
        }
        self.user_loc = locations[0] as? CLLocation
        self.user_location = "\( locations[0].coordinate.latitude ), \( locations[0].coordinate.longitude )"
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
        serverNum = Bakkle.developerTools ? NSUserDefaults.standardUserDefaults().integerForKey("server") : Bakkle.defaultServerNum
        switch( serverNum )
        {
            case 0: self.url_base = Bakkle.servers[0]
            //case 0: self.url_base = "https://PRODCLUSTER-16628191.us-west-2.elb.amazonaws.com/"
            case 1: self.url_base = Bakkle.servers[1]
            case 2: self.url_base = Bakkle.servers[2]
            case 3: self.url_base = Bakkle.servers[3]
            case 4: self.url_base = Bakkle.servers[4]
            //case 4: self.url_base = "http://137.112.57.140:8000/"
            case 5: self.url_base = Bakkle.servers[5] //Patrick
            case 6: self.url_base = Bakkle.servers[6] //Xinyu
            case 7: self.url_base = Bakkle.servers[7] // Joe
            default: self.url_base = Bakkle.servers[Bakkle.defaultServerNum]
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
    func settings() {
            let url:NSURL? = NSURL(string: url_base + url_settings)
            let request = NSMutableURLRequest(URL: url!)
        
            request.HTTPMethod = "GET"
            let postString = ""
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
                        var settings_dict :NSDictionary = responseDict.valueForKey("settings_dict") as! NSDictionary
                        
                        if(settings_dict.valueForKey("feed_items_to_load") != nil){
                            self.feed_items_to_load = settings_dict.valueForKey("feed_items_to_load")!.integerValue!
                        }
                        if(settings_dict.valueForKey("image_height") != nil){
                            self.image_height = settings_dict.valueForKey("image_height")!.integerValue!
                        }
                        if(settings_dict.valueForKey("image_width") != nil){
                            self.image_width = settings_dict.valueForKey("image_width")!.integerValue!
                        }
                        if(settings_dict.valueForKey("image_quality") != nil){
                            self.image_quality = settings_dict.valueForKey("image_quality")!.floatValue!
                        }
                        if(settings_dict.valueForKey("image_precache") != nil){
                            self.image_precache = settings_dict.valueForKey("image_precache")!.integerValue!
                        }
                        
                    }
                } else {
                    //TODO: Trigger reattempt to connect timer.
                }
            }
            task.resume()
    }

    
    /* register and login using facebook */
    func facebook(email: String, gender: String, username: String,
        name: String, userid: String, locale: String, first_name: String, last_name: String, success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_facebook)
        let request = NSMutableURLRequest(URL: url!)
        
        self.facebook_id_str = userid
        self.facebook_id = userid.toInt()
            
        request.HTTPMethod = "POST"
        let postString = "email=\(email)&name=\(name)&user_name=\(username)&gender=\(gender)&user_id=\(userid)&locale=\(locale)&first_name=\(first_name)&last_name=\(last_name)&device_uuid=\(self.deviceUUID)&flavor=\(self.flavor)"
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
                    let facebookProfileImageUrlString = "http://graph.facebook.com/\(Bakkle.sharedInstance.facebook_id_str)/picture?width=250&height=250"
                    self.profileImgURL = NSURL(string: facebookProfileImageUrlString)

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
            let postString = "device_uuid=\(self.deviceUUID)&user_id=\(self.facebook_id_str)&screen_width=\(screen_width)&screen_height=\(screen_height)&app_version=\(a)&app_build=\(b)&user_location=\(encLocation)&is_ios=true&flavor=\(self.flavor)"
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
                    var accountId = split(self.auth_token) {$0 == "_"}
                    self.account_id = accountId[1].toInt()
                    
                    // Connect to web socket
                    WSManager.setAuthenticationWithUUID(self.deviceUUID, withToken: self.auth_token)
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
            self.account_id = 0
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
        markItem(status, item_id: item_id, message: nil, success: {success()}, fail: {fail()})
    }
    
    func markItem(status: String, item_id: Int,  message: String?, success: ()->(), fail: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_mark + "\(status)/")
        let request = NSMutableURLRequest(URL: url!)
        
        let view_duration = 42 //TODO: this needs to be accepted as a parm
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&item_id=\(item_id)&view_duration=\(view_duration)&report_message=\(message)"
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
                            self.populateTrunk({})
                            NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkGarageUpdate, object: self)
                            break
                        case "hold":
                            self.populateHolding({})
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
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&search_text=\(self.search_text)&filter_distance=\(Int(self.filter_distance))&filter_price=\(Int(self.filter_price))&user_location=\(encLocation)"
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
    
    // take out tags right now, but if needed, will add later
    func addItem(title: String, description: String, location: String, price: String, images: [UIImage],item_id: NSInteger?, success: (item_id: Int?, item_url: String?)->(), fail: ()->() ) {
        // URL encode some vars.
        let escTitle = title.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let escDescription = description.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let escLocation = location.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
//        let escTags = tags.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var escPrice: String!
        if price == "take it!" {
            escPrice = "0.00"
        } else {
            escPrice = price.stringByReplacingOccurrencesOfString("$ ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        var postString : NSString;
        if(item_id != nil){
            postString = "device_uuid=\(self.deviceUUID)&title=\(escTitle)&description=\(escDescription)&location=\(escLocation)&auth_token=\(self.auth_token)&price=\(escPrice)&item_id=\(item_id!)"
        }
        else{
            postString = "device_uuid=\(self.deviceUUID)&title=\(escTitle)&description=\(escDescription)&location=\(escLocation)&auth_token=\(self.auth_token)&price=\(escPrice)"
        }
        let url: NSURL? = NSURL(string: url_base +  url_add_item + "?\(postString)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        var imageDataArray = [NSData]()
        for i in images {
            imageDataArray.append(UIImageJPEGRepresentation(i, 1.0))
        }
        
        var imageDataLength = 0;
        for i in imageDataArray {
            imageDataLength += i.length;
        }
        
        let postLength: String = "\(imageDataLength)"
        
        
        var boundary:String = "---------------------------14737809831466499882746641449"
        var contentType:String = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var body:NSMutableData = NSMutableData()
                
        //add all images as neccessary.
        for i in imageDataArray{
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
    
    func removeItem(item_id: NSInteger, success: ()->(), fail: ()->() ) {
        // URL encode some vars.
            var postString: String
            postString = "device_uuid=\(self.deviceUUID)&auth_token=\(self.auth_token)&item_id=\(item_id)"

        let url: NSURL? = NSURL(string: url_base +  url_delete_item + "?\(postString)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        info("[Bakkle] deleteItem")
        info("URL: \(url) METHOD: \(request.HTTPMethod)")
        
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
                success()
            } else {
                fail()
            }
        }
        task.resume()
    }
    
    func getAccount(account_id: NSInteger, success: ()->(), fail: ()->()) {
        var postString: String
         postString = "device_uuid=\(self.deviceUUID)&auth_token=\(self.auth_token)&accountId=\(account_id)"
        let url: NSURL? = NSURL(string: url_base +  url_getaccount + "?\(postString)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        info("[Bakkle] getAccount")
        info("URL: \(url) METHOD: \(request.HTTPMethod)")
        
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
                success()
            } else {
                fail()
            }
        }
        task.resume()
    }
    
    func setDescription(description: String!, success: ()->(), fail: ()->()) {
        var postString: String
        let escDescription = description.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        postString = "device_uuid=\(self.deviceUUID)&auth_token=\(self.auth_token)&description=\(escDescription)"
        let url: NSURL? = NSURL(string: url_base +  url_setdescription + "?\(postString)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        info("[Bakkle] getAccount")
        info("URL: \(url) METHOD: \(request.HTTPMethod)")
        
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
                success()
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
            self.filter_distance = 100
        }
        if let y = userDefaults.objectForKey("filter_price")    as? Float {
            self.filter_price = y
            println("Restored filter_price = \(y)")
        } else {
            self.filter_price = 100
        }
        NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFilterChanged, object: self)
    }
    func setFilter(ffilter_distance: Float, ffilter_price: Float) {
        self.filter_distance = ffilter_distance
        self.filter_price = ffilter_price
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(self.filter_distance, forKey: "filter_distance")
        userDefaults.setFloat(self.filter_price,    forKey: "filter_price")
        userDefaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFilterChanged, object: self)
    }
    
    func restoreData() {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        // reset instructional overlay
        if userDefaults.objectForKey("instruction") == nil{
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
                
                // restore TRUNK
                if let f = userDefaults.objectForKey("trunkItems") as? NSString {
                    var parseError: NSError?
                    var jsonData: NSData = f.dataUsingEncoding(NSUTF8StringEncoding)!
                    self.trunkItems = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! Array
                    self.info("Restored \( (self.trunkItems as Array).count) trunk items.")
                    NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkTrunkUpdate, object: self)
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
        
        // Store TRUNK
        if self.trunkItems != nil {
            let data1 = NSJSONSerialization.dataWithJSONObject(self.trunkItems, options: nil, error: nil)
            let string = NSString(data: data1!, encoding: NSUTF8StringEncoding)
            userDefaults.setObject(string, forKey: "trunkItems")
            self.info("Stored \( (self.trunkItems as Array).count) trunk items")
        }else {
            userDefaults.removeObjectForKey("trunkItems")
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