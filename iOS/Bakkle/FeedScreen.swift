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
    
    let options = MDCSwipeToChooseViewOptions()
    var swipeView : MDCSwipeToChooseView!
    
    @IBOutlet weak var backImgView: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var addItemBtn: UIButton!
    
    @IBOutlet weak var drawer: UIView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var seachBar: UISearchBar!
    
    var hardCoded = false
    
    var item_id = 42 //TODO: unhardcode this
    var loaded = false
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    @IBAction func btnX(sender: AnyObject) {
        self.swipeView.mdc_swipe(MDCSwipeDirection.Left)
        Bakkle.sharedInstance.markItem("meh", item_id: self.item_id, success: {}, fail: {})

    }
    @IBAction func btnCheck(sender: AnyObject) {
        self.swipeView.mdc_swipe(MDCSwipeDirection.Right)
        Bakkle.sharedInstance.markItem("want", item_id: self.item_id, success: {}, fail: {})
    }
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        progressIndicator.startAnimating()
        
        options.delegate = self
        options.likedText = "Want"
        options.likedColor = UIColor.greenColor()
        options.nopeText = "Meh"
        options.holdText = "Hold"
        options.reportText = "spam"
        options.holdColor = UIColor.blueColor()
        options.onPan = {(state) in
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
                println("let go to delete the picture.")
            }
        }
        
        /* Menu reveal */
        if self.revealViewController() != nil {
            menuBtn.targetForAction("revealToggle:", withSender: self)
            self.revealViewController().rearViewRevealWidth = 250
        }
        
        loaded = false
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.seachBar.resignFirstResponder()
    }
    
    /* Used at end of swipe, this is used to load the next item in the view */
    func loadNext() {
        println("[FeedScreen] removing item from feed")
        // Remove the item that was just marked from the view
        if Bakkle.sharedInstance.feedItems.count>0 {
            Bakkle.sharedInstance.feedItems.removeAtIndex(0)
        }
        
        // Put the swipe view back in the correct location
        resetSwipeView()
        
        // Load images into swipe and under view
        updateView(self.swipeView)
    }
    
    func resetSwipeView() {
        println("[FeedScreen] Resetting swipe view")
        
        /* First time page is loaded, swipe view will not exist and we need to create it. */
        self.swipeView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)

        /* If view is off the page we need to reset the view */
        if (state != nil && state.direction != MDCSwipeDirection.None) {
            self.swipeView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
        } else {
           //  View is already on the page AND is still visible. Do nothing
        }
    }
    
    /* Check server for new items */
    func checkForUpdates() {
        println("[FeedScreen] Requesting updates from server")
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            Bakkle.sharedInstance.populateFeed({
                println("[FeedScreen] updates received")
                dispatch_async(dispatch_get_main_queue()) {
                    self.resetSwipeView()
                    self.updateView(self.swipeView)
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let items = Bakkle.sharedInstance.feedItems {
            if Bakkle.sharedInstance.feedItems.count>0 {
                resetSwipeView()
                self.updateView(self.swipeView)
            }
        }

        // Always look for updates
        checkForUpdates()
    }
    
    func showAddItem(){
        var addItem: UIViewController = AddItem()
        presentViewController(addItem, animated: true, completion: nil)
    }
    
    func updateView(feedView: MDCSwipeToChooseView) {
        println("[FeedScreen] Updating view")
        if hardCoded {
            feedView.imageView.image = UIImage(named: "item-lawnmower.png")
            feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            view.addSubview(feedView)
        } else {
            if Bakkle.sharedInstance.feedItems.count > 0 {
                var topItem = Bakkle.sharedInstance.feedItems[0]
                if Bakkle.sharedInstance.feedItems.count > 1 {
                    var bottomItem = Bakkle.sharedInstance.feedItems[1]
                    var bottomItemDetail: NSDictionary = bottomItem.valueForKey("fields") as! NSDictionary!
                    let bottomURL: String = bottomItemDetail.valueForKey("image_urls") as! String
                }
                
                //println("top item is: \(topItem)")
                
                var itemDetails: NSDictionary = topItem.valueForKey("fields") as! NSDictionary!
                
                let imgURLs: String = itemDetails.valueForKey("image_urls") as! String
                
                //TEMP for testing, remove later.
                if imgURLs == "https://app.bakkle.com/img/b83bdbd.png" {
                    feedView.imageView.image = UIImage(named: "item-lawnmower.png")
                    feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    view.addSubview(feedView)
                    return
                }
                
                println("[FeedScreen] Downloading image \(imgURLs)")
                //println("urls are: \(imgURLs)")
                dispatch_async(dispatch_get_global_queue(
                    Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                    let imgURL = NSURL(string: imgURLs)
                    if let imgData = NSData(contentsOfURL: imgURL!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            println("[FeedScreen] displaying images")
                            feedView.imageView.image = UIImage(data: imgData)
                            feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                            super.view.addSubview(feedView)
                        }
                    }
                }
            } else {
                /* No items left in feed */
                
                //TODO: Display no items label
            }
        }
        loaded = true
    }
    
    func viewDidCancelSwipe(view: UIView!) {
        //println("You canceled the swipe")
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
            Bakkle.sharedInstance.markItem("meh", item_id: self.item_id, success: {}, fail: {})
            loaded = false
            loadNext()
        }
        else if direction == MDCSwipeDirection.Right {
            Bakkle.sharedInstance.markItem("want", item_id: self.item_id, success: {}, fail: {})
            loaded = false
            loadNext()
        }
        else if direction == MDCSwipeDirection.Up {
            Bakkle.sharedInstance.markItem("hold", item_id: self.item_id, success: {}, fail: {})
            loaded = false
            loadNext()
        }
        else if direction == MDCSwipeDirection.Down {
            Bakkle.sharedInstance.markItem("report", item_id: self.item_id, success: {}, fail: {})
            loaded = false
            loadNext()
        }
    }
    
}
