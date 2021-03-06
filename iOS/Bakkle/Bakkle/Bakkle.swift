//
//  Bakkle.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/8/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import Foundation
import Reachability
import TCMobileProvision

class Bakkle : NSObject, CLLocationManagerDelegate {
    
    let apiVersion: Float = 1.3
    var url_base: String          = "https://app.bakkle.com/"
    let url_login: String         = "account/login_facebook/"
    let url_settings: String      = "account/settings/"
    let url_logout: String        = "account/logout/"
    let url_guest_user_id: String = "account/guestuserid/"
    let url_local_user_id         = "account/localuserid/"
    let url_update_profile        = "account/updateprofile/"
    let url_set_password          = "account/setpassword/"
    let url_authenticate_local    = "account/authenticatelocal/"
    let url_facebook: String      = "account/facebook/"
    let url_register_local        = "account/register_local"
    let url_login_local           = "account/login_local"
    let url_register_push: String = "account/device/register_push/"
    let url_start_over: String    = "account/restart/"
    let url_reset: String         = "items/reset/"
    let url_mark: String          = "items/" //+status/
    let url_feed: String          = "items/feed/"
    let url_garage: String        = "items/get_seller_items/"
    let url_add_item: String      = "items/add_item/"
    let url_add_item_no_image: String = "items/add_item_no_image/"
    let url_delete_item: String   = "items/delete_item/"
    let url_send_chat: String     = "conversation/send_message/"
    let url_view_item: String     = "items/"
    let url_buyers_trunk: String        = "items/get_buyers_trunk/"
    let url_get_holding_pattern: String = "items/get_holding_pattern/"
    let url_buyertransactions: String   = "items/get_buyer_transactions/"
    let url_sellertransactions: String  = "items/get_seller_transactions/"
    let url_getaccount:String     = "account/get_account/"
    let url_setdescription:String = "account/set_description/"
   

    static let bkFeedUpdate     = "com.bakkle.feedUpdate"
    static let bkGarageUpdate   = "com.bakkle.garageUpdate"
    static let bkTrunkUpdate    = "com.bakkle.trunkUpdate"
    static let bkHoldingUpdate  = "com.bakkle.holdingUpdate"
    static let bkFilterChanged  = "com.bakkle.filterChanged"
    static let bkAppBecameActive = "com.bakkle.appBecameActive"
    
    static let bkPermissionAddItem     = "com.bakkle.permission.additem"
    
    // Account types
    static let bkAccountTypeGuest = 0
    static let bkAccountTypeFacebook = 2
    static let bkAccountTypeEmail = 3
    
    // DO NOT ENABLE if there is no way to select servers from settings file.
    static let developerTools   = false
    static let defaultServerNum = 0 // 0 = prod, 1 = prod cluster (sets default server in list below)
    static let servers   =   ["https://app.bakkle.com/",            // 0 (Production Single)
                              "https://app-cluster.bakkle.com/",    // 1 (Production Cluster)
                              "http://bakkle.rhventures.org:8000/"] // 2 (Test)
    
    static let serverNames = ["Production Server Single",
                              "Production Server Cluster",
                              "Test Server (Developers Only)"]
    
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
    var facebook_id_str: String!  // Store ID for 'logged in' for BOTH facebook and local, despite the name
                                  // when logged in with facebook, store the facebook id here. When logged in local, store the local ID here.
    var guest_id_str: String!     // Store ID for 'guest mode'. This is kept even after you login with a real account.
    var account_type: Int = Bakkle.bkAccountTypeGuest
    
    var duration:Double = 0
    var first_name: String!
    var last_name: String!
    var profileImgURL: NSURL!
    var email: String!
    
    var feedItems: [NSObject]!
    var garageItems: [NSObject]!
    var trunkItems: [NSObject]!
    var holdingItems: [NSObject]!
    // store marked items to avoid duplicate items
    var markedItem: [NSObject]! = Array()

    var userInfo: [NSObject: AnyObject]!

    var responseDict: NSDictionary!
    
    var filter_distance: Float = 100
    var filter_price: Float = 100
    
    var search_text: String = ""
    var user_location: String = ""
    var user_loc: CLLocation?
    
    var feed_items_to_load : Int = 20
    var image_height : Int = 660
    var image_width : Int = 660
    var image_quality : Float = 0.3
    var image_precache : Int = 10
    var video_length_sec : Double = 15.0
    var video_framerate : Int32 = 28
    
    var errorStr:String!
    
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
    func getItemURL( item_id: Int ) -> ( String ) {
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
    
    func updateduration(time:Double)
    {
        duration = time
        println("Worked")
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
    
    func isInternetConnected() -> Bool {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
        let networkStatus: NetworkStatus = reachability.currentReachabilityStatus()
        if networkStatus.hashValue == 0 {
            return false
        }else{
            return true
        }
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
                        if(settings_dict.valueForKey("video_length_sec") != nil){
                            self.video_length_sec = settings_dict.valueForKey("video_length_sec")!.doubleValue!
                        }
                        
                    }
                } else {
                    //TODO: Trigger reattempt to connect timer.
                }
            }
            task.resume()
    }
    
    // Check to see if user has permission to perform requested action
    func checkPermission(action:String) -> Bool {
        
        if action == Bakkle.bkPermissionAddItem {
            return Bakkle.sharedInstance.account_type == Bakkle.bkAccountTypeGuest
        }
        
        // Default
        return Bakkle.sharedInstance.account_type == Bakkle.bkAccountTypeGuest
    }
    
    func profileImageURL() -> String {
        if account_type == Bakkle.bkAccountTypeFacebook {
            return "http://graph.facebook.com/\(facebook_id_str)/picture"
        }
        if account_type == Bakkle.bkAccountTypeEmail {
            // TODO: lookup image URL
            return "https://app.bakkle.com/img/default_profile.png"
        }

        // Else assume guest
        return "https://app.bakkle.com/img/default_profile.png"
    }
    
    func guestUserID(device_uuid:String, success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_guest_user_id)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "device_uuid=\(device_uuid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("guest user id")
        info("URL: \(url)")
        info("METHOD: \(request.HTTPMethod)")
        info("BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
//                fail()
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Response: \(responseString)")
            
            var error: NSError? = error
            if data != nil && data.length != 0 {
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.guest_id_str = responseDict.valueForKey("userid") as! String
                    success()
                }else{
//                    fail()
                }
            }
        }
        task.resume()
    }
    
    func localUserID(email: String, device_uuid:String, success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_local_user_id)
        let request = NSMutableURLRequest(URL: url!)
        
        self.email = email
        
        request.HTTPMethod = "POST"
        let postString = "device_uuid=\(device_uuid)&email=\(email)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("local user id")
        info("URL: \(url)")
        info("METHOD: \(request.HTTPMethod)")
        info("BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Response: \(responseString)")
            
            var error: NSError? = error
            if data != nil && data.length != 0 {
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    
                    self.facebook_id_str = responseDict.valueForKey("userid") as! String
                    success()
                }
            }
        }
        task.resume()
    }
    
    func updateProfile(user_id: String, display_name:String, device_uuid:String) {
        let url:NSURL? = NSURL(string: url_base + url_update_profile)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "user_id=\(user_id)&name=\(display_name)&device_uuid=\(device_uuid)&flavor=1"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("guest user id")
        info("URL: \(url)")
        info("METHOD: \(request.HTTPMethod)")
        info("BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Response: \(responseString)")
            
            self.errorStr = ""
            
            var error: NSError? = error
            if data != nil && data.length != 0 {
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.info("successfully updated profile")
                } else {
                    self.errorStr = responseDict.valueForKey("message") as! String
                }
            }
        }
        task.resume()
    }
    
    func setPassword(user_id: String, device_uuid:String, password:String, success: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_set_password)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "user_id=\(user_id)&device_uuid=\(device_uuid)&flavor=1&password=\(password)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("guest user id")
        info("URL: \(url)")
        info("METHOD: \(request.HTTPMethod)")
        info("BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Response: \(responseString)")
            
            self.errorStr = ""
            
            var error: NSError? = error
            if data != nil && data.length != 0 {
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.info("password set successfully")
                    success()
                }
                else {
                    self.errorStr = responseDict.valueForKey("message") as! String
                }
            }
        }
        task.resume()
    }
    
    
    func authenticateLocal(user_id: String, device_uuid:String, password:String, success: ()->(), fail: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_authenticate_local)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let postString = "user_id=\(user_id)&device_uuid=\(device_uuid)&flavor=1&password=\(password)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("guest user id")
        info("URL: \(url)")
        info("METHOD: \(request.HTTPMethod)")
        info("BODY: \(postString)")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Response: \(responseString)")
            
            self.errorStr = ""
            
            var error: NSError? = error
            if data != nil && data.length != 0 {
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.info("successfult authenticated local account")
                    success()
                }
                else {
                    self.errorStr = responseDict.valueForKey("message") as! String
                    fail()
                }
            }
        }
        task.resume()
    }
    
    

    
    /* register and login using facebook */
    /* create account */
    func facebook(gender: String, name: String, userid: String, first_name: String, last_name: String, success: ()->(), fail: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_facebook)
        let request = NSMutableURLRequest(URL: url!)
        
        if self.account_type != 0 {
            self.facebook_id_str = userid
        }
        
        var avatarImageURL = ""
        if self.account_type == Bakkle.bkAccountTypeFacebook {
            avatarImageURL = "http://graph.facebook.com/\(userid)/picture"
        } else {
            avatarImageURL = "https://app.bakkle.com/img/default_profile.png"
        }
            
        request.HTTPMethod = "POST"
        let postString = "name=\(name)&gender=\(gender)&user_id=\(userid)&first_name=\(first_name)&last_name=\(last_name)&device_uuid=\(self.deviceUUID)&flavor=\(self.flavor)&avatar_image_url=\(avatarImageURL)&account_type=\(self.account_type)"
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
            
            self.errorStr = ""
            
            /* JSON parse */
            var error: NSError? = error
            if (data != nil && data.length != 0) {
                var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as! NSDictionary
                
                if responseDict.valueForKey("status")?.integerValue == 1 {
                    self.first_name = first_name
                    self.last_name = last_name
                    
                    self.profileImgURL = NSURL(string: self.profileImageURL())

                    success()
                }
                else {
                    self.errorStr = responseDict.valueForKey("message") as! String
                    fail()
                }
            } else {
                //TODO: Trigger reattempt to connect timer.
            }
        }
        task.resume()
    }
    
    // register use device uuid
    
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
        var user_id: String
        if Bakkle.sharedInstance.account_type == Bakkle.bkAccountTypeGuest {
            user_id = self.guest_id_str
        }else{
            user_id = self.facebook_id_str
        }
            let postString = "device_uuid=\(self.deviceUUID)&user_id=\(user_id)&screen_width=\(screen_width)&screen_height=\(screen_height)&app_version=\(a)&app_build=\(b)&user_location=\(encLocation)&is_ios=true&flavor=\(self.flavor)"
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
                    let display_name = responseDict.valueForKey("display_name") as! String
                    let nameArr = split(display_name) {$0 == " "}
                    self.first_name = nameArr[0]
                    self.last_name = ""
                    if nameArr.count == 2 {
                        self.last_name = nameArr[1]
                    }
                    self.profileImgURL = NSURL(string: self.profileImageURL())
                    // Connect to web socket
                    WSManager.setAuthenticationWithUUID(self.deviceUUID, withToken: self.auth_token)
                    WSManager.connectWS()
                    success()
                } else {
                    Bakkle.sharedInstance.logout({})
                    fail()
                }
            }
            task.resume()
    }
    
    /* logout */
    func logout(success: () -> ()) {
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
            
            self.account_type = Bakkle.bkAccountTypeGuest
            success()
        }
        task.resume()
    }

    /* register device for push notifications */
    func register_push(deviceToken: NSData) {
        let url:NSURL? = NSURL(string: url_base + url_register_push)
        let request = NSMutableURLRequest(URL: url!)

        request.HTTPMethod = "POST"
        let apsnMode = self.apnsMode()
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&device_token=\(deviceToken)&apns_mode=\(apnsMode)"
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
    func markItem(status: String, item_id: Int,  message: String? = "", duration: Double = 0, success: ()->(), fail: ()->()) {
        let url:NSURL? = NSURL(string: url_base + url_mark + "\(status)/")
        let request = NSMutableURLRequest(URL: url!)
        
        let view_duration = duration //TODO: this needs to be accepted as a parm
        request.HTTPMethod = "POST"
        
        var postString : String
        if(message != nil){
            
            postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&item_id=\(item_id)&view_duration=\(view_duration)&report_message=\(message!)"

        }
        else{
            
            postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&item_id=\(item_id)&view_duration=\(view_duration)"

        }
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        println("[Bakkle] markItem")
        println("URL: \(url) METHOD: \(request.HTTPMethod) BODY: \(postString)")
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    data, response, error in
                    
                    if let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        self.debg("Response: \(responseString)")
                        
                        self.markedItem.append(item_id)
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
    
    /* Populates the watch list with items from the server */
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
    
    /* populate more items from server if less than 10 items in feed*/
    func requestMoreItems() {
        if(feedItems.count < 10){
            populateFeed({
                
            });
        }
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
                    if let feedEl: [NSObject] = self.responseDict.valueForKey("feed") as? Array {
                        var newItems = false
                        for item in feedEl {
                            if self.feedItems == nil {
                                self.feedItems = Array()
                            }
                            if !contains(self.feedItems,item) {
                                if !contains(self.markedItem, item.valueForKey("pk") as! NSObject) {
                                    let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
                                    dispatch_async(lockQueue, { () -> Void in
                                        self.feedItems.append(item)
                                        newItems = true;
                                    })
                                }
                            }
                        }
                        self.markedItem = []
//                        self.feedItems = self.responseDict.valueForKey("feed") as! Array
                        self.persistData()
                        if newItems {
                            NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFeedUpdate, object: self)
                        }
                    }
                    //note called on success, not 'new items'
                    
                    success()
                }
            }
        }
        task.resume()
    }
    
    /* Put all the meh items back after feed view is already out of items */
    func resetFeed(success: ()->()){
        let url: NSURL? = NSURL(string: url_base + url_start_over)
        let request = NSMutableURLRequest(URL: url!)
        
        let encLocation = user_location.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        request.HTTPMethod = "POST"
        let postString = "auth_token=\(self.auth_token)&device_uuid=\(self.deviceUUID)&accountId=\(self.account_id)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        info("[Bakkle] resetFeed")
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
                    // TODO later
                    if let feedEl: AnyObject = self.responseDict["feed"] {
                        //TODO: only update new items.
                        self.feedItems = self.responseDict.valueForKey("feed") as! Array
                        self.persistData()
                        NSNotificationCenter.defaultCenter().postNotificationName(Bakkle.bkFeedUpdate, object: self)
                    }
                    success()
                }
            }
        }
        task.resume()

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
    //                let image_url: String = self.getImageURL(item_id)
                    success()
            } else {
                fail()
            }
        }
        task.resume()
    }
    
    /* Returns true if the url is valid */
    func urlIsValid(urlString: String?) -> Bool {
        if urlString != nil {
            if let url = NSURL(string: urlString!) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        
        return false
    }
    
    // take out tags right now, but if needed, will add later
    func addItem(title: String, description: String, location: String, price: String, images: [NSData], videos: [NSData], item_id: NSInteger?, success: (item_id: Int?, image_url: String?)->(), fail: ()->() ) {
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
        
        var imageDataLength = 0;
        for i in images {
            imageDataLength += i.length;
        }
        
        let postLength: String = "\(imageDataLength)"
        
        
        var boundary:String = "---------------------------14737809831466499882746641449"
        var contentType:String = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var body:NSMutableData = NSMutableData()
                
        //add all images as neccessary.
        for i in images{
            body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData(i)
            body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        }
        for i in videos{
            body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData("Content-Disposition: form-data; name=\"videos\"; filename=\"video.mp4\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
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
                let image_url: String = self.responseDict.valueForKey("image_url") as! String
                success(item_id: item_id, image_url: image_url)
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
    
    func getAccount(account_id: NSInteger, success: (account: NSDictionary)->(), fail: ()->()) {
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
            self.responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as! NSDictionary
            self.debg("RESPONSE DICT IS: \(self.responseDict)")
            
            if Bakkle.sharedInstance.responseDict.valueForKey("status")?.integerValue == 1 {
                success(account: self.responseDict.valueForKey("account") as! NSDictionary)
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
    
    func previewImageForLocalVideo(url:NSURL) -> UIImage? {
        let asset = AVURLAsset(URL: url, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        //If possible - take not the first frame (it could be completely black or white on camara's videos)
        time.value = min(time.value, 2)
        
        var error: NSError?
        let imageRef = imageGenerator.copyCGImageAtTime(time, actualTime: nil, error: &error)
        
        if error != nil {
            NSLog("Image generation failed with error \(error)")
            return nil
        }
        
        // Side lengths are the ratio * smallest length (width or height)
        var lengthRatio: CGFloat = 1.0 / 3.0
        var length: CGFloat = min(CGFloat(self.image_width), CGFloat(self.image_height)) * lengthRatio
        var distToSide: CGFloat = length / (2.0 * sqrt(3.0))
        var distToVertex: CGFloat = length / sqrt(3.0)
        
        //  |\   Is the orientation of the play triangle, where:
        //  | \           point1 = top most vertex
        //  | /           point2 = rightmost vertex
        //  |/           point3 = bottom most vertex
        var point1: CGPoint = CGPointMake(CGFloat(self.image_width) / 2.0 - distToSide, CGFloat(self.image_height) / 2.0 - length / 2.0)
        var point2: CGPoint = CGPointMake(CGFloat(self.image_width) / 2.0 + distToVertex, CGFloat(self.image_height) / 2.0)
        var point3: CGPoint = CGPointMake(CGFloat(self.image_width) / 2.0 - distToSide, CGFloat(self.image_height) / 2.0 + length / 2.0)
        
        var imageWithTriangle = UIImage(CGImage: imageRef)!
        
        // Crop to Square (from UIImage+Resize, without the dispatch_async blocks)
        let contextSize: CGSize = imageWithTriangle.size
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        imageWithTriangle = UIImage(CGImage: CGImageCreateWithImageInRect(imageWithTriangle.CGImage, CGRectMake(posX, posY, width, height)), scale: imageWithTriangle.scale, orientation: imageWithTriangle.imageOrientation)!
        
        // Resize (from UIImage+Resize, without the dispatch_async blocks)
        var newSize:CGSize = CGSizeMake(CGFloat(self.image_width), CGFloat(self.image_height))
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        imageWithTriangle.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Take the cropped and resized image, then average the rgb values with dark gray color to darken it
        UIGraphicsBeginImageContextWithOptions(newImage.size, false, newImage.scale)
        var context = UIGraphicsGetCurrentContext()
        var area = CGRectMake(0, 0, newImage.size.width, newImage.size.height)
        CGContextSaveGState(context)
        CGContextClipToMask(context, area, newImage.CGImage)
        UIColor.darkGrayColor().set()
        CGContextFillRect(context, area)
        CGContextRestoreGState(context)
        CGContextSetBlendMode(context, kCGBlendModeMultiply)
        CGContextDrawImage(context, area, newImage.CGImage)
        var returnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Take the darkened image and draw an equilateral triangle with a flat edge facing to the left in the center of the image
        UIGraphicsBeginImageContext(newImage.size)
        context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, CGRectMake(0, 0, returnImage.size.width, returnImage.size.height), returnImage.CGImage)
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.65).setStroke()
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.65).set()
        CGContextSetLineJoin(context, kCGLineJoinRound)
        CGContextSetLineWidth(context, 8.0)
        var triangle = CGPathCreateMutable()
        CGPathMoveToPoint(triangle, nil, point1.x, point1.y)
        CGPathAddLineToPoint(triangle, nil, point2.x, point2.y)
        CGPathAddLineToPoint(triangle, nil, point3.x, point3.y)
        CGPathCloseSubpath(triangle)
        CGContextAddPath(context, triangle)
        CGContextFillPath(context)
        returnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return returnImage
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
            self.filter_distance = 101
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
        if let temp = userDefaults.objectForKey("guest_id_str") as? String {
            self.guest_id_str = temp
            self.info("Restored \( self.guest_id_str ) guest_id_str.")
        }
        if let temp = userDefaults.objectForKey("facebook_id_str") as? String {
            self.facebook_id_str = temp
            self.info("Restored \( self.facebook_id_str ) facebook_id_str.")
        }
        if let temp = userDefaults.objectForKey("account_type") as? Int {
            self.account_type = temp
            self.info("Restored \( self.account_type ) account_type.")
        }
        if let temp = userDefaults.objectForKey("first_name") as? String {
            self.first_name = temp
            self.info("Restored \( self.first_name ) first_name.")
        }
        if let temp = userDefaults.objectForKey("last_name") as? String {
            self.last_name = temp
            self.info("Restored \( self.last_name ) last_name.")
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

        // Store HOLDING
        if self.holdingItems != nil {
            let data3 = NSJSONSerialization.dataWithJSONObject(self.holdingItems, options: nil, error: nil)
            let string3 = NSString(data: data3!, encoding: NSUTF8StringEncoding)
            userDefaults.setObject(string3,   forKey: "holdingItems")
            self.info("Stored \( (self.holdingItems as Array).count) holding items")
        } else {
            userDefaults.removeObjectForKey("holdingItems")
        }
        
//        if let temp = userDefaults.objectForKey("first_name") as? Int {
//            self.first_name = temp
//            self.info("Restored \( self.first_name ) first_name.")
//        }
//        if let temp = userDefaults.objectForKey("last_name") as? Int {
//            self.last_name = temp
//            self.info("Restored \( self.last_name ) last_name.")
//        }
        

        // Store VERSION
        userDefaults.setObject(self.appVersion().build, forKey: "version")
        self.info("Stored version = \(self.appVersion().build)")
        
        // Store GUESTID
        userDefaults.setObject(self.guest_id_str, forKey: "guest_id_str")
        self.info("Stored guest_id_str = \(self.guest_id_str)")

        // Store FACEBOOK/LOCALID
        userDefaults.setObject(self.facebook_id_str, forKey: "facebook_id_str")
        self.info("Stored facebook_id_str = \(self.facebook_id_str)")

        // Store ACCOUNT TYPE
        userDefaults.setObject(self.account_type, forKey: "account_type")
        self.info("Stored account_type = \(self.account_type)")

        // Store FIRST_NAME
        userDefaults.setObject(self.first_name, forKey: "first_name")
        self.info("Stored first_name = \(self.first_name)")
        
        // Store LAST NAME
        userDefaults.setObject(self.last_name, forKey: "last_name")
        self.info("Stored last_name = \(self.last_name)")
        
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
 
    // production
    func apnsMode() -> String {
        let mobileprovisionPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("embedded.mobileprovision")
        let data = NSData(contentsOfFile: mobileprovisionPath)
        let mobileprovision = TCMobileProvision(data: data)
        let entitlements = mobileprovision.dict["Entitlements"]! as! NSDictionary
        let apsEnvironment = entitlements["aps-environment"] as! String
        
        return apsEnvironment
    }
    
}