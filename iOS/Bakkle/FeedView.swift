//
//  FeedScreen.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/18/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Photos
import Haneke

class FeedView: UIViewController, UIImagePickerControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate, MDCSwipeToChooseDelegate, UIAlertViewDelegate {

    let menuSegue = "presentNav"
    let itemDetailSegue = "ItemDetailSegue"
    let refineSegue = "RefineSegue"
    let options = MDCSwipeToChooseViewOptions()
    
    var fromCamera: Bool! = false
    var searching = false
    var state : MDCPanState!
    // the first card in the feedView
    var swipeView : MDCSwipeToChooseView!
    // the card behind the first card
    var bottomView : MDCSwipeToChooseView!
    
    // for instructional overlay appeared above the feedView
    var instructionImgView: UIImageView!
    var effectView: UIVisualEffectView!
    
    var itemDetailTap: UITapGestureRecognizer!
    var item_id = 42 //TODO: unhardcode this
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var noNewItemsLabel: UILabel!
    @IBOutlet weak var drawer: UIView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var refineButton: UIButton!
    @IBOutlet weak var btnAddItem: UIButton!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var logoImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Bakkle.sharedInstance.flavor == 2){
            self.view.backgroundColor = Bakkle.sharedInstance.theme_base
            self.titleBar.backgroundColor = Bakkle.sharedInstance.theme_baseDark
            
            var logo : UIImage = UIImage(named: "Goodwill Logo-White.png")!
            logoImageView.image = logo;
            logoImageViewHeight.constant = 20;
            logoImageViewWidth.constant = 140;
        }
        
        // Always look for updates
        requestUpdates()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        progressIndicator.startAnimating()
        
        // for swipe
        options.delegate = self
        
        /* Menu reveal */
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = 270
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Item detail tap
        itemDetailTap = UITapGestureRecognizer(target: self, action: "goToDetails")
        
        // dismiss tap
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
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
        setupButtons()
        
        // Removed border around search bar.
        searchBar.barTintColor = titleBar.backgroundColor
        searchBar.layer.borderColor = titleBar.backgroundColor?.CGColor
        searchBar.layer.borderWidth = 1
        
        if Bakkle.sharedInstance.flavor == 2 {
            btnAddItem.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    
        // Always look for updates
        requestUpdates()

        filterChanged()
        
        resetSwipeView()
        
        println("Loading existing feed items")
        if fromCamera == false {
            if let items = Bakkle.sharedInstance.feedItems {
                if items.count>0 {
                    self.updateView()
                }
            }
        }

        fromCamera = false

    }
    
    func displayInstruction() {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.boolForKey("instruction") && swipeView != nil && instructionImgView == nil {
            // disable user interaction and show instruction
            self.searchBar.userInteractionEnabled = false
            self.refineButton.userInteractionEnabled = false
            self.menuBtn.userInteractionEnabled = false
            self.itemDetailTap.enabled = false
            self.btnAddItem.userInteractionEnabled = false
            self.revealViewController().panGestureRecognizer().enabled = false
            self.constructInstructionView()
        }
    }
    
    /* instruction overlay code begins */
    // create the instruction image and show it on screen
    func constructInstructionView() {
            effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
            instructionImgView = UIImageView(frame: CGRectMake(drawer.frame.origin.x, drawer.frame.origin.y+drawer.superview!.frame.origin.y, drawer.frame.size.width, drawer.frame.size.height))
            effectView.frame = instructionImgView.frame
            instructionImgView.contentMode = UIViewContentMode.ScaleToFill
            instructionImgView.clipsToBounds = true
            instructionImgView.userInteractionEnabled = true
            instructionImgView.image = UIImage(named: "InstructionScreen.png")
            let closeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            closeBtn.addTarget(self, action: "closeBtnPressed:", forControlEvents: .TouchUpInside)
            instructionImgView.addSubview(closeBtn)
            var mainWindow: UIWindow = UIApplication .sharedApplication().keyWindow!
            mainWindow.addSubview(effectView)
            mainWindow.addSubview(instructionImgView)
    }
    
    func closeBtnPressed(sender: UIButton!) {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setBool(false, forKey: "instruction")
        self.searchBar.userInteractionEnabled = true
        self.refineButton.userInteractionEnabled = true
        self.menuBtn.userInteractionEnabled = true
        self.btnAddItem.userInteractionEnabled = true
        self.itemDetailTap.enabled = true
        self.revealViewController().panGestureRecognizer().enabled = true
        instructionImgView.removeFromSuperview()
        effectView.removeFromSuperview()
    }
    
    /* instruction overlay code ends */
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
        
        refineButton.layer.borderWidth = 1
        refineButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.revealViewController().revealToggleAnimated(true)
        self.searchBar.resignFirstResponder()
        searching = false
    }
    
    /* UISearch Bar delegate */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        Bakkle.sharedInstance.search_text = searchText
        requestUpdates()
        //TODO: need to fix queuing mechanism so multple requests are not dispatched.
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
        searching = true
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    /* End search bar delegate */
    
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
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
    
    
    @IBAction func btnRefine(sender: AnyObject) {
        self.dismissKeyboard()
    }
    
    func goToDetails() {
        if searching {
            self.searchBar.resignFirstResponder()
            searching = false
        }else{
            let itemDet = ItemDetails()
            println("GOES IN DETAILS VIEW CONTROLLER")
            self.performSegueWithIdentifier(itemDetailSegue, sender: self)
        }
    }
    
    
    /* Used at end of swipe, this is used to load the next item in the view */
    func loadNext() {
        println("[FeedScreen] removing item from feed")
        
        // Put the swipe view back in the correct location
//        resetSwipeView()
        
        if(Bakkle.sharedInstance.feedItems.count < 10){
            requestUpdates();
        }
        
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
                self.swipeView = MDCSwipeToChooseView(frame: CGRectMake(drawer.frame.origin.x, drawer.frame.origin.y+drawer.superview!.frame.origin.y, drawer.frame.size.width, drawer.frame.size.height), options: options)
                self.swipeView.addGestureRecognizer(itemDetailTap)
                if Bakkle.sharedInstance.feedItems.count > 1 {
                    if self.bottomView != nil {
                        self.bottomView.removeFromSuperview()
                        self.bottomView = nil
                    }
                    self.bottomView = MDCSwipeToChooseView(frame: self.swipeView.frame, options: nil)
                    self.view.insertSubview(self.bottomView, belowSubview: self.swipeView)
                }
        }
        
        
        /* If view is off the page we need to reset the view */
        else if (state != nil && state.direction != MDCSwipeDirection.None) {
            
            //if view is still on page, yet has been swiped in a direction, remove it.
            if self.swipeView != nil {
                self.swipeView.removeFromSuperview()
                self.swipeView = nil
            }
            
            //promote bottomView to prevent having to recreate swipeView
            self.swipeView = self.bottomView
            
            //create new bottomView
            self.bottomView = MDCSwipeToChooseView(frame: self.swipeView.frame, options: nil)
            
            //add gesture recognizer to top view (swipeView)
            self.swipeView.addGestureRecognizer(itemDetailTap)
        }
        
        // always check that if it is necessary to display instruction, to prevent the nil of swipeView when the first time open the app
        self.displayInstruction()
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
            var revealViewController: SWRevealViewController! = self.revealViewController()
            if revealViewController == nil {
                self.resetSwipeView()
                self.updateView()
            }else{
                if self.revealViewController().frontViewPosition == FrontViewPosition.Left{
                    self.resetSwipeView()
                    self.updateView()
                }
            }
        }
    }
    
    /* helper function */
    func setupView(view: MDCSwipeToChooseView!, item: NSDictionary!) {
        let imgURLs = item.valueForKey("image_urls") as! NSArray
        let topTitle: String = item.valueForKey("title") as! String
        let topPrice: String = item.valueForKey("price") as! String
        
        let sellersProfile = item.valueForKey("seller") as! NSDictionary
        let facebookID = sellersProfile.valueForKey("facebook_id") as! String
        let sellersName = sellersProfile.valueForKey("display_name") as! String
        var facebookProfileImgString = "http://graph.facebook.com/\(facebookID)/picture?width=142&height=142"
    
        let dividedName = split(sellersName) {$0 == " "}
        let firstName = dividedName[0] as String
        
        let firstURL = imgURLs[0] as! String
        let imgURL = NSURL(string: firstURL)
        let profileImgURL = NSURL(string: facebookProfileImgString)
        
        view.nameLabel.text = topTitle
        
        var myString : String = ""
        if suffix(topPrice, 2) == "00" {
            let withoutZeroes = "$\((topPrice as NSString).integerValue)"
            myString = " " + withoutZeroes
        } else {
            myString = " $" + topPrice
        }
        view.priceLabel.text = myString
        view.sellerName.text = firstName
//        view.ratingView.rating = 3.5
    
        if imgURL != nil {
            view.bottomBlurImg.hnk_setImageFromURL(imgURL!)
            view.imageView.hnk_setImageFromURL(imgURL!)
            view.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            view.profileImg.image = Bakkle.sharedInstance.flavor == 2 ? UIImage(named: "gwIcon@2x.png") : UIImage(data: NSData(contentsOfURL: profileImgURL!)!)
        }
        
        if view == self.swipeView {
            if self.swipeView.imageView.image == nil {
                self.swipeView.imageView.image = UIImage(named: "loading.png")
                self.swipeView.userInteractionEnabled = false
            }
            if imgURL != nil {
                self.swipeView.userInteractionEnabled = true
            }
        }
        if view == self.bottomView {
            self.bottomView.userInteractionEnabled = false
        }
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
                
                let topItem = Bakkle.sharedInstance.feedItems[0] as! NSDictionary
                if let x: AnyObject = topItem.valueForKey("pk") {
                    self.item_id = Int(x.intValue)
                }
                setupView(self.swipeView, item: topItem)
                self.view.addSubview(swipeView)
                
                if Bakkle.sharedInstance.feedItems.count > 1 {
                    if self.bottomView != nil {
                        self.bottomView.alpha = 1
                                
                        var bottomItem = Bakkle.sharedInstance.feedItems[1] as! NSDictionary
                        setupView(self.bottomView, item: bottomItem)
                    }
                }
                else {
                    println("Only one item, hiding bottom card")
                    // only 1 item (top card)
                    if self.bottomView != nil {
                        self.bottomView.removeFromSuperview()
                        self.bottomView.alpha = 1
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
        self.refreshData()
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
        switch direction {
        case MDCSwipeDirection.Left:
            Bakkle.sharedInstance.markItem("meh", item_id: self.item_id, success: {}, fail: {})
            loadNext()
            break
        case MDCSwipeDirection.Right:
            Bakkle.sharedInstance.markItem("want", item_id: self.item_id, success: {}, fail: {})
            loadNext()
            break
        case MDCSwipeDirection.Up:
            Bakkle.sharedInstance.markItem("hold", item_id: self.item_id, success: {}, fail: {})
            loadNext()
            break
        case MDCSwipeDirection.Down:
            let alertController = UIAlertController(title: "Alert", message:"INPUT BELOW", preferredStyle: .Alert)
            var report: UITextField!
            let confirmAction = UIAlertAction(title: "Confirm", style: .Default, handler: { action in
                if report != nil {
                    println(report.text)
                }
                Bakkle.sharedInstance.markItem("report", item_id: self.item_id, success: {}, fail: {})
                self.loadNext()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { action in
                self.refreshData()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            alertController.addTextFieldWithConfigurationHandler({ (textField: UITextField!) -> Void in
                report = textField
                })
            presentViewController(alertController, animated: true, completion: nil)
            break
        default: break
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == self.itemDetailSegue {
            let destinationVC = segue.destinationViewController as! ItemDetails
            
            destinationVC.item = Bakkle.sharedInstance.feedItems[0] as! NSDictionary
        }
        if segue.identifier == self.refineSegue {
            let destinationVC = segue.destinationViewController as! RefineView
            destinationVC.parentView = self
            if searchBar.text != nil {
                destinationVC.search_text = searchBar.text
            }
        }
    }
}
