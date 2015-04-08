//
//  FeedScreen.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/18/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class FeedScreen: UIViewController, MDCSwipeToChooseDelegate {

    var state : MDCPanState!
    
    let menuSegue = "presentNav"
    
    var account_id : Int!
    
    var feedItems : [NSObject]!
    
    var transitionOperator = TransitionOperator()
    
    let feedURL = NSURL(string: "https://app.bakkle.com/items/feed/")
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var addItemBtn: UIBarButtonItem!
    
    @IBOutlet weak var drawer: UIView!
    

    @IBAction func menuButtonPressed(sender: AnyObject) {
        drawer.frame.origin = CGPoint(x: 0, y: 0)
        //self.revealViewController().revealToggleAnimated(true)
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
        var shortImg = UIImage(named: "menubtn.png")
        menuBtn.setBackButtonBackgroundImage(shortImg, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        self.navBar.topItem?.title = "Bakkle Logo"
        
       // self.navigationItem.leftBarButtonItem = UINavigationItem.to
        
        var options = MDCSwipeToChooseViewOptions()
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
        
        view.imageView.image = UIImage(named: "item-lawnmower.png")
        view.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(view)

        /* Menu reveal */
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = "revealToggle:"
            self.revealViewController().rearViewRevealWidth = 250
        }
    }
    
    func populateFeed(){
        var postString = "account_id=\(account_id)"
        
        let request = NSMutableURLRequest(URL: feedURL!)
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println("error= \(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            var error: NSError? = error
            
            var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary!
            
            println("RESPONSE DICT IS: \(responseDict)")
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                self.feedItems = responseDict.valueForKey("feed") as [NSObject]!
                
                
            }
        })
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
            self.mark("meh", item_id: 1)    //TODO: Needs item_id
        }
        else if direction == MDCSwipeDirection.Right {
            self.mark("want", item_id: 1)   //TODO: Needs item_id
        }
        else if direction == MDCSwipeDirection.Up {
            self.mark("hold", item_id: 1)   //TODO: Needs item_id
        }
        else if direction == MDCSwipeDirection.Down {
            self.mark("report", item_id: 1) //TODO: Needs item_id
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
