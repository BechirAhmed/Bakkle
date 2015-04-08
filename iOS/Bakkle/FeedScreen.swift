//
//  FeedScreen.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/18/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class FeedScreen: UIViewController, MDCSwipeToChooseDelegate {

    var state : MDCPanState!
    
    let menuSegue = "presentNav"
    
    var account_id : Int!
    
    var feedItems : [NSObject]!
    
    let options = MDCSwipeToChooseViewOptions()
    
    var transitionOperator = TransitionOperator()
    
    let feedURL = NSURL(string: "https://app.bakkle.com/items/feed/")
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var addItemBtn: UIButton!
    
    @IBOutlet weak var drawer: UIView!
    
    var hardCoded = false
    

    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    @IBAction func btnX(sender: AnyObject) {
        self.mark("meh", item_id: 1)
    }
    @IBAction func btnCheck(sender: AnyObject) {
        self.mark("want", item_id: 1)
    }
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        options.delegate = self
        options.likedText = "Want"
        options.likedColor = UIColor.greenColor()
        options.nopeText = "Meh"
        options.holdText = "Hold"
        options.holdColor = UIColor.blueColor()
        options.onPan = {(state) in
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
                println("let go to delete the picture.")
            }
        }
        
        let view : MDCSwipeToChooseView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
        
        if hardCoded {
            view.imageView.image = UIImage(named: "item-lawnmower.png")
            view.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.view.addSubview(view)
        } else {
            populateFeed(view)
        }
            
        /* Menu reveal */
        if self.revealViewController() != nil {
            menuBtn.targetForAction("revealToggle:", withSender: self)
            self.revealViewController().rearViewRevealWidth = 250
        }
    }
    
    func showAddItem(){
        var addItem: UIViewController = AddItem()
        presentViewController(addItem, animated: true, completion: nil)
    }
    
    func populateFeed(feedView: MDCSwipeToChooseView){
        if hardCoded {
            feedView.imageView.image = UIImage(named: "item-lawnmower.png")
            feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            view.addSubview(feedView)
        }
            
        var postString = "account_id=\(2)"
        
        let request = NSMutableURLRequest(URL: feedURL!)
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println("error= \(error)")
                return
            }
            let tempStr = "{\"status\": 1, \"feed\": [{\"fields\": {\"status\": \"Active\", \"times_reported\": 0, \"description\": \"Year old orange push mower. Some wear and sun fadding. Was kept outside and not stored in shed.\", \"title\": \"Orange Push Mower\", \"price\": \"50.25\", \"tags\": \"lawnmower, orange, somewear\", \"image_urls\": \"https://app.bakkle.com/img/b8347df.jpg\", \"seller\": 1, \"post_date\": \"2015-04-08T13:50:02.850Z\", \"location\": \"39.417672,-87.330438\", \"method\": \"Pick-up\"}, \"model\": \"items.items\", \"pk\": 10}]}"

            let tempData = tempStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
            let responseString: String = NSString(data: tempData!, encoding: NSUTF8StringEncoding)!
           // println("RESPONSE STRING IN FEED IS: \(responseString)")
            var parseError: NSError?
            
            var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(tempData!, options: NSJSONReadingOptions.MutableContainers, error: &parseError) as NSDictionary!
            
            
            println("RESPONSE DICT IS: \(responseDict)")
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                self.feedItems = responseDict.valueForKey("feed") as [NSObject]!
                var topItem = self.feedItems[0]
                println("top item is: \(topItem)")
                var itemDetails: NSDictionary = topItem.valueForKey("fields") as NSDictionary!
                let imgURLs: String = itemDetails.valueForKey("image_urls") as String
                println("urls are: \(imgURLs)")
                let imgURL = NSURL(string: imgURLs)
                if let imgData = NSData(contentsOfURL: imgURL!) {
                    feedView.imageView.image = UIImage(data: imgData)
                    feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    self.view.addSubview(feedView)
                }
                
            }
        })
        task.resume()
    }
    
    func viewDidCancelSwipe(view: UIView!) {
        println("You canceled the swipe")
    }
    
    func view(view: UIView!, shouldBeChosenWithDirection direction: MDCSwipeDirection) -> Bool {
        if direction == MDCSwipeDirection.Left || direction == MDCSwipeDirection.Right || direction == MDCSwipeDirection.Up || direction == MDCSwipeDirection.Down {
            return true
        } else {
            UIView.animateWithDuration(0.16, animations: { () -> Void in
                view.transform = CGAffineTransformIdentity
                var superView : UIView = self.view.superview!
                self.view.center = superView.convertPoint(superView.center, fromView: superView.superview)
            })
            return false
        }
    }
    
    
    func view(view: UIView!, wasChosenWithDirection direction: MDCSwipeDirection) {
        if direction == MDCSwipeDirection.Left {
            self.revealViewController().revealToggleAnimated(true)
           // self.mark("meh", item_id: 1)    //TODO: Needs item_id
        }
        else if direction == MDCSwipeDirection.Right {
           // self.mark("want", item_id: 1)   //TODO: Needs item_id
        }
        else if direction == MDCSwipeDirection.Up {
           // self.mark("hold", item_id: 1)   //TODO: Needs item_id
        }
        else if direction == MDCSwipeDirection.Down {
           // self.mark("report", item_id: 1) //TODO: Needs item_id
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == menuSegue {
            let toViewController = segue.destinationViewController as Menu
            self.modalPresentationStyle = UIModalPresentationStyle.Custom
            toViewController.transitioningDelegate = self.transitionOperator
        }
    }
    
    let baseUrlString : String = "https://app.bakkle.com/"
    
    /* Mark item as MEH on server */
    func markMeh(item_id: Int){
        
        let url:NSURL? = NSURL(string: baseUrlString.stringByAppendingString("items/meh/"))
        let request = NSMutableURLRequest(URL: url!)
        var postString : String = "account_id=\(self.account_id)&item_id=\(item_id)"
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            var error: NSError? = error
            
            var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as NSDictionary!
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                // Success
            }
        }
        task.resume()
    }

    /* Mark item as 'status' on server */
    func mark(status: String, item_id: Int){
        
        println("Marking item: \(item_id) as \(status) on server for account: \(account_id)")
        let url:NSURL? = NSURL(string: baseUrlString.stringByAppendingString("items/\(status)/"))
        let request = NSMutableURLRequest(URL: url!)
        var postString : String = "account_id=\(self.account_id)&item_id=\(item_id)"
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            var error: NSError? = error
            
            var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as NSDictionary!
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                // Success
            }
        }
        task.resume()
    }
    
    
}
