//
//  FeedScreen.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/18/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Social
import Photos
import Haneke

class FeedScreen: UIViewController, UIImagePickerControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate, MDCSwipeToChooseDelegate {

    var state : MDCPanState!

    let menuSegue = "presentNav"
    let addItemSegue = "AddItemSegue"
    let itemDetailSegue = "ItemDetailSegue"
    
    let options = MDCSwipeToChooseViewOptions()
    var swipeView : MDCSwipeToChooseView!
    var bottomView : MDCSwipeToChooseView!
    var infoView: UIView!
    
    var chosenImage: UIImage?
    var fromCamera: Bool! = false
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var noNewItemsLabel: UILabel!
    
    @IBOutlet weak var drawer: UIView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var seachBar: UISearchBar!
    
    var hardCoded = false
    var itemDetailTap: UITapGestureRecognizer!
    
    var item_id = 42 //TODO: unhardcode this
    
    @IBOutlet weak var navBar: UINavigationBar!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        progressIndicator.startAnimating()

        // for swipe
        options.delegate = self
        
        /* Menu reveal */
        if self.revealViewController() != nil {
            //menuBtn.targetForAction("revealToggle:", withSender: self)
            self.revealViewController().rearViewRevealWidth = 270
        }
        
        // Item detail tap
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        itemDetailTap = UITapGestureRecognizer(target: self, action: "goToDetails")
        
        // Register for feed updates
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkFeedUpdate, object: nil, queue: mainQueue) { _ in
            println("Received feed update")
            self.refreshData()
        }
        var observer2 = notificationCenter.addObserverForName(Bakkle.bkFilterChanged, object: nil, queue: mainQueue) { _ in
            self.filterChanged()
        }
        
        //TODO: Timer to check for new feed items
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        filterChanged()

        // Reset the swipeview if it is missing
//        if self.swipeView == nil {
            resetSwipeView()
//        }
        enableSwipe()
        
        println("Loading existing feed items")
        if fromCamera == false {
            if let items = Bakkle.sharedInstance.feedItems {
                if Bakkle.sharedInstance.feedItems.count>0 {
                    self.updateView()
                }
            }
        }
        
        // Always look for updates
        requestUpdates()
        fromCamera = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.disableSwipe()
        self.revealViewController().revealToggleAnimated(true)
        
        //TODO: remove this when feed is updated via push
        requestUpdates()
    }
    @IBAction func btnX(sender: AnyObject) {
        if self.swipeView != nil {
            self.swipeView.mdc_swipe(MDCSwipeDirection.Left)
        }
    }
    @IBAction func btnCheck(sender: AnyObject) {
        if self.swipeView != nil {
            self.swipeView.mdc_swipe(MDCSwipeDirection.Right)
        }
    }
    
    func disableSwipe() {
        if self.swipeView != nil {
            self.swipeView.userInteractionEnabled = false
            self.swipeView = nil
        }
        if self.bottomView != nil {
            self.bottomView.userInteractionEnabled = false
            self.bottomView = nil
        }
    }
    func enableSwipe() {
        if self.swipeView != nil {
            self.swipeView.userInteractionEnabled = true
            self.swipeView = nil
        }
        if self.bottomView != nil {
            self.bottomView.userInteractionEnabled = true
            self.bottomView = nil
        }
    }
    /* UISearch Bar delegate */
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        Bakkle.sharedInstance.search_text = searchText
        requestUpdates()
        //TODO: need to fix queuing mechanism so multple requests are not dispatched.
    }
    
    /* End search bar delegate */
    
    
    func dismissKeyboard() {
        self.seachBar.resignFirstResponder()
    }
    
    /* Call when filter parameters change. Updates text when all cards are exhausted */
    func filterChanged() {
        println("Filter parameters changed")
        if Bakkle.sharedInstance.filter_distance < 100 {
            self.noNewItemsLabel.text = "There are no new items within \(Int(Bakkle.sharedInstance.filter_distance)) miles."
        } else {
            self.noNewItemsLabel.text = "There are no new items near you."
        }
    }
    
    func goToDetails() {
        let itemDet = ItemDetails()
        println("GOES IN DETAILS VIEW CONTROLLER")
        self.performSegueWithIdentifier(itemDetailSegue, sender: self)
        
    }
    
    /* Used at end of swipe, this is used to load the next item in the view */
    func loadNext() {
        println("[FeedScreen] removing item from feed")

        // Put the swipe view back in the correct location
        resetSwipeView()
        
        // Remove the item that was just marked from the view
        if Bakkle.sharedInstance.feedItems.count>0 {
            Bakkle.sharedInstance.feedItems.removeAtIndex(0)
        }
        
        if Bakkle.sharedInstance.feedItems.count == 1 {
            println("1 item left")
            if self.bottomView != nil {
                self.bottomView.removeFromSuperview()
                self.requestUpdates()
            }
        }

        if Bakkle.sharedInstance.feedItems.count == 0 {
            println("0 items left")
            if self.bottomView != nil {
                self.bottomView.removeFromSuperview()
            }
            if self.swipeView != nil {
                self.swipeView.removeFromSuperview()
            }
        }

        // Load images into swipe and under view
        resetSwipeView()
        updateView()
    }
    
    func resetSwipeView() {
        println("[FeedScreen] Resetting swipe view")
        
        /* First time page is loaded, swipe view will not exist and we need to create it. */
        if Bakkle.sharedInstance.feedItems != nil &&
           Bakkle.sharedInstance.feedItems.count > 0 {
            if self.swipeView != nil {
                self.swipeView.removeFromSuperview()
                self.swipeView = nil
            }
            self.swipeView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
            self.swipeView.addGestureRecognizer(itemDetailTap)
            if Bakkle.sharedInstance.feedItems.count > 1 {
                if self.bottomView != nil {
                    self.bottomView.removeFromSuperview()
                    self.bottomView = nil
                }
                self.bottomView = MDCSwipeToChooseView(frame: CGRectMake(self.swipeView.frame.origin.x , self.swipeView.frame.origin.y , self.swipeView.frame.width, self.swipeView.frame.height), options: nil)
                self.view.insertSubview(self.bottomView, belowSubview: self.swipeView)
            }
        }
        
        
        /* If view is off the page we need to reset the view */
        if (state != nil && state.direction != MDCSwipeDirection.None) {
            if self.swipeView != nil {
                self.swipeView.removeFromSuperview()
                self.swipeView = nil
            }
            self.swipeView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
            if self.bottomView != nil {
                self.bottomView.removeFromSuperview()
                self.bottomView = nil
            }
            self.bottomView = MDCSwipeToChooseView(frame: CGRectMake(self.swipeView.frame.origin.x, self.swipeView.frame.origin.y, self.swipeView.frame.width, self.swipeView.frame.height), options: nil)
            self.view.insertSubview(self.bottomView, belowSubview: self.swipeView)
            self.swipeView.addGestureRecognizer(itemDetailTap)
        } else {
           //  View is already on the page AND is still visible. Do nothing
        }
    }
    
    /* Check server for new items */
    func requestUpdates() {
        println("[FeedScreen] Requesting updates from server")
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            Bakkle.sharedInstance.populateFeed({})
        }
    }
    
    /* Called when new data is available to display.*/
    func refreshData() {
        dispatch_async(dispatch_get_main_queue()) {
            //TODO: Check items 0 and 1, if they are the same, do nothing
            self.resetSwipeView()
            self.updateView()
        }
    }
    
    func constructInfoView() {
        var bottomHeight: CGFloat = 60.0
        var bottomFrame: CGRect = CGRectMake(0, CGRectGetHeight(swipeView.bounds) - bottomHeight, CGRectGetWidth(swipeView.bounds), bottomHeight)
        self.infoView = UIView(frame: bottomFrame)
        self.infoView.backgroundColor = UIColor.yellowColor()
        self.infoView.clipsToBounds = true
        self.infoView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        swipeView.addSubview(self.infoView)
    }
    
    func updateView() {
        println("[FeedScreen] Updating view ")
        if Bakkle.sharedInstance.feedItems == nil {
            return
        }
        println("updateView items: \(Bakkle.sharedInstance.feedItems.count)")
        if Bakkle.sharedInstance.feedItems.count > 0 {
            if self.swipeView != nil {
                self.swipeView.alpha = 1
            
            let topItem = Bakkle.sharedInstance.feedItems[0]
            if let x: AnyObject = topItem.valueForKey("pk") {
                self.item_id = Int(x.intValue)
            }
            let imgURLs = topItem.valueForKey("image_urls") as! NSArray
            let topTitle: String = topItem.valueForKey("title") as! String
            let topPrice: String = topItem.valueForKey("price") as! String
            
            //println("[FeedScreen] Downloading image (top) \(imgURLs)")
            self.swipeView.nameLabel.text = topTitle
         //   self.swipeView.priceLabel.text = "\(topPrice)"
            self.swipeView.imageView.image = UIImage(named: "loading.png")
            dispatch_async(dispatch_get_global_queue(
                Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                    let firstURL = imgURLs[0] as! String
                    let imgURL = NSURL(string: firstURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        //println("[FeedScreen] displaying image (top)")
                        if imgURL == nil {
                            
                        }else{
                            self.swipeView.imageView.hnk_setImageFromURL(imgURL!)
                            self.swipeView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                        }
                        super.view.addSubview(self.swipeView)
                    }
            
                    if Bakkle.sharedInstance.feedItems.count > 1 {
                        if self.bottomView != nil {
                            self.bottomView.alpha = 1

                            var bottomItem = Bakkle.sharedInstance.feedItems[1]
                            let bottomURLs = bottomItem.valueForKey("image_urls") as! NSArray
                            let bottomTitle: String = bottomItem.valueForKey("title") as! String
                            let bottomPrice: String = bottomItem.valueForKey("price") as! String
                            
                            self.bottomView.userInteractionEnabled = false
                            
                            //println("[FeedScreen] Downloading image (bottom) \(bottomURLs)")
                            let bottomURL = bottomURLs[0] as! String
                            let imgURL = NSURL(string: bottomURL)
                            dispatch_async(dispatch_get_main_queue()) {
                                //println("[FeedScreen] displaying image (bottom)")
                                if let x = imgURL {
                                    self.bottomView.imageView.hnk_setImageFromURL(imgURL!)

                                    self.bottomView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                                }
                                self.bottomView.nameLabel.text = bottomTitle
                            //    self.bottomView.priceLabel.text = "$\(bottomPrice)"
                            }
                        }
                    } else {
                        println("Only one item, hiding bottom card")
                        // only 1 item (top card)
                        if self.bottomView != nil {
                            self.bottomView.removeFromSuperview()
                            self.bottomView.alpha = 1
                        }
                    }
                }
            }
        } else {
            println("No items, hiding both cards")
            /* No items left in feed */
            if self.swipeView != nil {
                self.swipeView.removeFromSuperview()
                self.swipeView.alpha = 0
            }
            if self.bottomView != nil {
                self.bottomView.removeFromSuperview()
                self.bottomView.alpha = 0
            }
            
            self.progressIndicator.alpha = 0
            noNewItemsLabel.alpha = 1
        }
    }
    
    func viewDidCancelSwipe(view: UIView!) {
        // Do nothing. Resets the swipe view
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
            loadNext()
        }
        else if direction == MDCSwipeDirection.Right {
            Bakkle.sharedInstance.markItem("want", item_id: self.item_id, success: {}, fail: {})
            loadNext()
        }
        else if direction == MDCSwipeDirection.Up {
            Bakkle.sharedInstance.markItem("hold", item_id: self.item_id, success: {}, fail: {})
            loadNext()
        }
        else if direction == MDCSwipeDirection.Down {
            Bakkle.sharedInstance.markItem("report", item_id: self.item_id, success: {}, fail: {})
            loadNext()
        }
        
        if bottomView != nil {
            self.bottomView.alpha = 0.0
            self.view.insertSubview(self.bottomView, belowSubview: self.swipeView)
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.bottomView.alpha = 1.0
            }, completion: nil)
        }
    }

    
    /* Camera */
    let albumName = "Bakkle"
    
    func showAddItem(){
        var addItem: UIViewController = AddItem()
        presentViewController(addItem, animated: true, completion: nil)
    }
    
    // Display camera as first step of add-item
    @IBAction func cameraBtn(sender: AnyObject) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: false, completion: nil)
            fromCamera = true
            
        } else{
            //no camera available
            var alert = UIAlertController(title: "Sorry", message: "Bakkle requires a picture when selling items", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(false, completion: nil)

                /* This allows us to test add item without camera on simulator */
                if UIDevice.currentDevice().model == "iPhone Simulator" {
                    self.performSegueWithIdentifier(self.addItemSegue, sender: self)
                }

            }))
            self.presentViewController(alert, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        fromCamera = true
        picker.dismissViewControllerAnimated(true, completion: nil)
       // checkForUpdates()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosen = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.chosenImage = chosen
        dismissViewControllerAnimated(false, completion: {
            self.performSegueWithIdentifier(self.addItemSegue, sender: self)
        })
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == self.addItemSegue {
            let destinationVC = segue.destinationViewController as! AddItem
            destinationVC.itemImage = self.chosenImage
        }
    }
}
