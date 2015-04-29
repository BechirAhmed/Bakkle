//
//  FeedScreen.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/18/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Social

class FeedScreen: UIViewController, MDCSwipeToChooseDelegate {

    var state : MDCPanState!

    let ChooseItemViewImageLabelWidth:CGFloat = 42.0;
    let menuSegue = "presentNav"
    let itemDetailSegue = "ItemDetailSegue"
    
    let options = MDCSwipeToChooseViewOptions()
    var swipeView : MDCSwipeToChooseView!
    var bottomView : MDCSwipeToChooseView!
    var infoView: UIView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var noNewItemsLabel: UILabel!
    
    @IBOutlet weak var addItemBtn: UIButton!
    
    @IBOutlet weak var drawer: UIView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var seachBar: UISearchBar!
    
    var hardCoded = false
    var itemDetailTap: UITapGestureRecognizer!
    
    var item_id = 42 //TODO: unhardcode this
    var loaded = false
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    @IBAction func btnX(sender: AnyObject) {
        self.swipeView.mdc_swipe(MDCSwipeDirection.Left)
    }
    @IBAction func btnCheck(sender: AnyObject) {
        self.swipeView.mdc_swipe(MDCSwipeDirection.Right)
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
        options.holdText = "Holding"
        options.reportText = "report"
        options.holdColor = UIColor.whiteColor()

        if hardCoded {
            options.onPan = { state -> Void in
                if self.bottomView != nil {
                    self.bottomView.alpha = 0.0
                    var frame: CGRect = self.frontCardViewFrame()
                    self.bottomView.frame = CGRectMake(frame.origin.x, frame.origin.y - (state.thresholdRatio *     10.0), CGRectGetWidth(frame), CGRectGetHeight(frame))
                }
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
        
        itemDetailTap = UITapGestureRecognizer(target: self, action: "goToDetails")
    }
    
    func frontCardViewFrame() -> CGRect{
        var horizontalPadding:CGFloat = 20.0
        var topPadding:CGFloat = 60.0
        var bottomPadding:CGFloat = 200.0
        return CGRectMake(horizontalPadding,topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding * 2), CGRectGetHeight(self.view.frame) - bottomPadding)
    }
    
    func dismissKeyboard() {
        self.seachBar.resignFirstResponder()
    }
    
    func goToDetails() {
        let itemDet = ItemDetails()
        println("GOES IN DETAILS VIEW CONTROLLER")
       // itemDet.imgDet.image = UIImage(named: "tiger.jpg")
        self.performSegueWithIdentifier(itemDetailSegue, sender: self)
        
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
        self.bottomView = MDCSwipeToChooseView(frame: CGRectMake(self.swipeView.frame.origin.x, self.swipeView.frame.origin.y + 10, self.swipeView.frame.width, self.swipeView.frame.height + 10), options: nil)
        self.view.insertSubview(self.bottomView, belowSubview: self.swipeView)
        self.swipeView.addGestureRecognizer(itemDetailTap)
        
        /* If view is off the page we need to reset the view */
        if (state != nil && state.direction != MDCSwipeDirection.None) {
            self.swipeView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
            self.bottomView = MDCSwipeToChooseView(frame: CGRectMake(self.swipeView.frame.origin.x, self.swipeView.frame.origin.y + 10, self.swipeView.frame.width, self.swipeView.frame.height), options: nil)
            self.view.insertSubview(self.bottomView, belowSubview: self.swipeView)
            self.swipeView.addGestureRecognizer(itemDetailTap)
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
    
    func constructInfoView() {
        var bottomHeight: CGFloat = 60.0
        var bottomFrame: CGRect = CGRectMake(0, CGRectGetHeight(swipeView.bounds) - bottomHeight, CGRectGetWidth(swipeView.bounds), bottomHeight)
        self.infoView = UIView(frame: bottomFrame)
        self.infoView.backgroundColor = UIColor.whiteColor()
        self.infoView.clipsToBounds = true
        self.infoView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        swipeView.addSubview(self.infoView)
    }
    
    func updateView(feedView: MDCSwipeToChooseView) {
        println("[FeedScreen] Updating view")
        if Bakkle.sharedInstance.feedItems.count > 0 {
            let topItem = Bakkle.sharedInstance.feedItems[0]
            if let x: AnyObject = topItem.valueForKey("pk") {
                self.item_id = Int(x.intValue)
            }
           // var itemDetails: NSDictionary = topItem.valueForKey("feed") as! NSDictionary
            let imgURLs = topItem.valueForKey("image_urls") as! NSArray
            let topTitle: String = topItem.valueForKey("title") as! String
            let topPrice: String = topItem.valueForKey("price") as! String
            
            println("[FeedScreen] Downloading image (top) \(imgURLs)")
            feedView.nameLabel.text = topTitle + ",  $" + topPrice
            dispatch_async(dispatch_get_global_queue(
                Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                    let firstURL = imgURLs[0].valueForKey("url") as! String
                    let imgURL = NSURL(string: firstURL)
                    if let imgData = NSData(contentsOfURL: imgURL!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            println("[FeedScreen] displaying image (top)")
                            feedView.imageView.image = UIImage(data: imgData)
                            feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                        
                            super.view.addSubview(feedView)
                        }
                    }
            
            
                    if Bakkle.sharedInstance.feedItems.count > 1 {
                        var bottomItem = Bakkle.sharedInstance.feedItems[1]
                      //  var bottomItemDetails: NSDictionary = bottomItem.valueForKey("fields") as! NSDictionary
                        let bottomURLs = bottomItem.valueForKey("image_urls") as! NSArray
                        let bottomTitle: String = bottomItem.valueForKey("title") as! String
                        let bottomPrice: String = bottomItem.valueForKey("price") as! String
                        
                        self.bottomView.nameLabel.text = bottomTitle + ",  $" + bottomPrice
                        
                        self.bottomView.userInteractionEnabled = false
                        
                        println("[FeedScreen] Downloading image (bottom) \(bottomURLs)")
                        
                        let bottomURL = bottomURLs[0].valueForKey("url") as! String
                        let imgURL = NSURL(string: bottomURL)
                        if let imgData = NSData(contentsOfURL: imgURL!) {
                            dispatch_async(dispatch_get_main_queue()) {
                                println("[FeedScreen] displaying image (bottom)")
                                self.bottomView.imageView.image = UIImage(data: imgData)
                                self.bottomView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                            }
                        }
                    }
                }
            
            // Load BOTTOM item card
            
//                dispatch_async(dispatch_get_global_queue(
//                    Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            
                                
                         //   }
               //     }
         //   }
        } else {
            /* No items left in feed */
            noNewItemsLabel.alpha = 1
        }
       // }
        loaded = true
    }
    
    func viewDidCancelSwipe(view: UIView!) {
        //println("You canceled the swipe")
    }
    
    func buildImageLabelViewLeftOf(x:CGFloat, image:UIImage, text:NSString) -> ImageLabelView{
        var frame:CGRect = CGRect(x:x-ChooseItemViewImageLabelWidth, y: 0,
            width: ChooseItemViewImageLabelWidth,
            height: CGRectGetHeight(self.infoView.bounds))
        var view:ImageLabelView = ImageLabelView(frame:frame, image:image, text:text)
        view.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        return view
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
        
        if bottomView != nil {
            self.swipeView = self.bottomView
        }

        if bottomView != nil {
            self.bottomView.alpha = 0.0
            self.view.insertSubview(self.bottomView, belowSubview: self.swipeView)
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.bottomView.alpha = 1.0
            }, completion: nil)
        }
    }
    
}
