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
    var model: String = UIDevice.currentDevice().model
    
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
    
    // For start a chat view
    @IBOutlet weak var startChatView: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var makeAnOfferButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewDescriptionLabel: UILabel!
    @IBOutlet weak var startChatItemImage: UIImageView!
    @IBOutlet weak var startChatViewOriginX: NSLayoutConstraint!
    @IBOutlet weak var startChatViewOriginY: NSLayoutConstraint!
    @IBOutlet weak var darkenStartAChat: UIView!
    @IBOutlet weak var noInternectView: UIView!
    
    var itemData: NSDictionary?
    var sendMessageContext = 0
    var keepBrowsingContext = 0
    var recordstart = NSDate()
    var recordtime: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display status bar every time the screen shows up
        UIApplication.sharedApplication().statusBarHidden = false
        
        // check if comes from a notification
        if ((Bakkle.sharedInstance.userInfo) != nil){
            showChatViewController()
        }
        
        // check if it is a goodwill app
        if(Bakkle.sharedInstance.flavor == Bakkle.GOODWILL){
            self.view.backgroundColor = Bakkle.sharedInstance.theme_base
            self.titleBar.backgroundColor = Bakkle.sharedInstance.theme_baseDark
            
            var logo : UIImage = UIImage(named: "Goodwill Logo-White.png")!
            logoImageView.image = logo;
            logoImageViewHeight.constant = 20;
            logoImageViewWidth.constant = 140;
            
            btnAddItem.hidden = true
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
        
        // dismiss keyboard tap
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
        
        // Start a Chat Swiping
        setupChatSwiping()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // set up the no internet view
        setupNoInternetView()
        
        if Bakkle.sharedInstance.flavor == Bakkle.GOODWILL {
            var goodwillLogo: UIImageView = UIImageView(frame: CGRectMake(btnAddItem.frame.origin.x, logoImageView.frame.midY + 2.5, 35.0, 35.0))
            goodwillLogo.image = UIImage(named: "gwIcon@2x.png")!
            goodwillLogo.layer.cornerRadius = 7.0
            //            goodwillLogo.layer.borderWidth = 1.0
            //            goodwillLogo.layer.borderColor = UIColor.whiteColor().CGColor
            goodwillLogo.layer.masksToBounds = true
            self.view.addSubview(goodwillLogo)
        }
        
        self.makeAnOfferButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.sendMessageButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.startChatItemImage.layer.borderColor = UIColor.whiteColor().CGColor
        self.startChatItemImage.layer.masksToBounds = true
        self.startChatViewOriginX.constant = self.startChatView.frame.width * -1.5
        self.startChatViewOriginY.constant = 50
        self.startChatView.layoutIfNeeded()
        
        self.revealViewController().panGestureRecognizer().enabled = true
        
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
        
       
        
        // check internet connection
        checkInternetConnection()
        
        
        
    }
    
    func displayInstruction(view: MDCSwipeToChooseView!) {
        // disable user interaction and show instruction
        self.searchBar.userInteractionEnabled = false
        self.refineButton.userInteractionEnabled = false
        self.menuBtn.userInteractionEnabled = false
        self.itemDetailTap.enabled = false
        self.btnAddItem.userInteractionEnabled = false
        self.revealViewController().panGestureRecognizer().enabled = false
        
        // set up image for tutorial
        view.imageView.image = UIImage(named: "InstructionScreen-new.png")
    }
    
    func setupNoInternetView(){
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
        visualEffectView.frame = CGRectMake(0, 0, noInternectView.frame.width, noInternectView.frame.height)
        self.noInternectView.addSubview(visualEffectView)
        var backgroundImageView = UIImageView(frame: CGRectMake(0, 0, noInternectView.frame.width, noInternectView.frame.height))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
        backgroundImageView.image = UIImage(named: "no-internet.png")
        backgroundImageView.clipsToBounds = true
        self.noInternectView.addSubview(backgroundImageView)
    }
    
    func checkInternetConnection(){
        if Bakkle.sharedInstance.isInternetConnected() {
            self.noInternectView.hidden = true
            self.btnAddItem.enabled = true
        }else{
            self.noInternectView.hidden = false
            self.view.bringSubviewToFront(self.noInternectView)
            self.btnAddItem.enabled = false
        }

    }
    
    func showChatViewController(){
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        var userInfo = Bakkle.sharedInstance.userInfo
        Bakkle.sharedInstance.userInfo = nil
        if let chat_id = userInfo["chat_id"] as? Int {
            let item_id = userInfo["item_id"] as? Int
            let seller_id = userInfo["seller_id"] as? Int
            let buyer_id = userInfo["buyer_id"] as? Int
            if seller_id == Bakkle.sharedInstance.account_id {
                // user is a seller
                Bakkle.sharedInstance.getAccount(buyer_id as NSInteger!, success: { (account: NSDictionary) -> () in
                    //                        let account = (Bakkle.sharedInstance.responseDict as NSDictionary!).valueForKey("account") as! NSDictionary
                    let name = account.valueForKey("display_name") as! String
                    let buyer = User(facebookID: account.valueForKey("facebook_id") as! String, accountID: buyer_id!, firstName: name, lastName: name)
                    var chatItem: NSDictionary? = nil
                    for index in 0...Bakkle.sharedInstance.garageItems.count-1 {
                        if Bakkle.sharedInstance.garageItems[index].valueForKey("pk") as? Int == item_id {
                            chatItem = Bakkle.sharedInstance.garageItems[index] as? NSDictionary
                        }
                    }
                    let buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chat_id)
                    let chatViewController = ChatViewController(chat: buyerChat)
                    chatViewController.item = chatItem
                    chatViewController.seller = chatItem!.valueForKey("seller") as! NSDictionary
                    chatViewController.isBuyer = false
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController!.pushViewController(chatViewController, animated: true)
                    })
                    
                    }, fail: { () -> () in
                })
            }else if buyer_id == Bakkle.sharedInstance.account_id {
                // user is a buyer
                let buyer = User(facebookID: Bakkle.sharedInstance.facebook_id_str,accountID: Bakkle.sharedInstance.account_id,
                    firstName: Bakkle.sharedInstance.first_name, lastName: Bakkle.sharedInstance.last_name)
                var chatItem: NSDictionary? = nil
                for index in 0...Bakkle.sharedInstance.trunkItems.count-1 {
                    if (Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as! NSDictionary).valueForKey("pk") as? Int == item_id {
                        chatItem = Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as? NSDictionary
                    }
                }
                let buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chat_id)
                let chatViewController = ChatViewController(chat: buyerChat)
                chatViewController.item = chatItem
                chatViewController.seller = chatItem!.valueForKey("seller") as! NSDictionary
                chatViewController.isBuyer = true
                self.navigationController!.pushViewController(chatViewController, animated: true)
            }
        }
        
    }
    
    func  setupChatSwiping(){
        var startChatViewOptions: MDCSwipeOptions = MDCSwipeOptions.new()
        startChatViewOptions.delegate = self
        startChatViewOptions.threshold = self.view.frame.width / 4
        
        startChatViewOptions.onPan = { state -> Void in
            self.darkenStartAChat.alpha = state.thresholdRatio / 3 * 2
            
            var rotation = CGFloat(-M_PI_4)
            // Rotation multiplier is the distance moved (x) / total distance (according to what the position it ends on after close)
            var rotationMultiplier = (self.view.frame.midX - self.startChatView.frame.midX) / (self.startChatView.frame.width * 2)
            self.startChatView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,  rotation * rotationMultiplier)
            
            if state.thresholdRatio == 0.0 {
                self.makeAnOfferButton.sendActionsForControlEvents(.TouchUpOutside)
                self.sendMessageButton.sendActionsForControlEvents(.TouchUpOutside)
            }
        }
        
        startChatViewOptions.onChosen = { state -> Void in
            self.closeStartAChat(state)
        }
        
        self.startChatView.mdc_swipeToChooseSetup(startChatViewOptions)
    }
    
    
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
        if searchText == "" {
            requestUpdates()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
        searching = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        requestUpdates()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        requestUpdates()
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
        recordstart = NSDate();
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
                var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                self.swipeView = MDCSwipeToChooseView(frame: CGRectMake(drawer.frame.origin.x, drawer.frame.origin.y+drawer.superview!.frame.origin.y, drawer.frame.size.width, drawer.frame.size.height), options: options, tutorial: userDefaults.boolForKey("instruction"), goodwill: Bakkle.sharedInstance.flavor == Bakkle.GOODWILL, ipad: model == "iPad")
                self.swipeView.addGestureRecognizer(itemDetailTap)
                if Bakkle.sharedInstance.feedItems.count > 1 {
                    if self.bottomView != nil {
                        self.bottomView.removeFromSuperview()
                        self.bottomView = nil
                    }
                    self.bottomView = MDCSwipeToChooseView(frame: self.swipeView.frame, options: nil, tutorial: false, goodwill: Bakkle.sharedInstance.flavor == Bakkle.GOODWILL, ipad: model == "iPad")
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
            self.bottomView = MDCSwipeToChooseView(frame: self.swipeView.frame, options: nil, tutorial: false, goodwill: Bakkle.sharedInstance.flavor == Bakkle.GOODWILL, ipad: model == "iPad")
            
            //add gesture recognizer to top view (swipeView)
            self.swipeView.addGestureRecognizer(itemDetailTap)
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
        if self.startChatView.hidden {
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
    }
    
    /* helper function */
    func setupView(view: MDCSwipeToChooseView!, item: NSDictionary!) {
        let imgURLs = item.valueForKey("image_urls") as! NSArray
        let topTitle: String = item.valueForKey("title") as! String
        let topPrice: String = item.valueForKey("price") as! String
        
        let sellersProfile = item.valueForKey("seller") as! NSDictionary
        let sellerFacebookID = sellersProfile.valueForKey("facebook_id") as! String
        let sellersName = sellersProfile.valueForKey("display_name") as! String
        let sellersImageProfile = sellersProfile.valueForKey("avatar_image_url") as! String
        
        //        let profileImageURL = NSURL(string)
        
        let dividedName = split(sellersName) {$0 == " "}
        let firstName = dividedName[0] as String
        
        let firstURL = imgURLs[0] as! String
        let imgURL = NSURL(string: firstURL)
        
        view.nameLabel.text = topTitle
        
        var myString : String = ""
        
        //  Trim the zeroes after the decimal.
        if suffix(topPrice, 2) == "00" {
            let withoutZeroes = (topPrice as NSString).integerValue
            if withoutZeroes == 0 {
                myString = " Offer"
            } else {
                myString = " $\(withoutZeroes)"
            }
        } else {
            myString = " $" + topPrice
        }
        view.priceLabel.text = myString
        //        view.sellerName.text = firstName
        //        view.ratingView.rating = 3.5
        
        if imgURL != nil {
            view.bottomBlurImg.hnk_setImageFromURL(imgURL!)
            view.imageView.hnk_setImageFromURL(imgURL!)
            view.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            
            //            view.profileImg.hnk_setImageFromURL(NSURL(string: sellersImageProfile)!)
            if (view == self.swipeView){
                self.swipeView.userInteractionEnabled = true
            }
        }
        
        
        if self.swipeView.imageView.image == nil {
            self.swipeView.imageView.image = UIImage(named: "loading.png")
        }
        if self.bottomView != nil && view == self.bottomView {
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
                
                if self.swipeView.tutorial  {
                    displayInstruction(self.swipeView)
                }else{
                    setupView(self.swipeView, item: topItem)
                }
                
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
    
        checkInternetConnection()
    }
    
    func viewDidCancelSwipe(view: UIView!) {
        // Do nothing. Resets the swipe view
        self.refreshData()
    }
    
    func view(view: UIView!, shouldBeChosenWithDirection direction: MDCSwipeDirection) -> Bool {
        if Bakkle.sharedInstance.flavor == Bakkle.GOODWILL {
            if direction == MDCSwipeDirection.Left || direction == MDCSwipeDirection.Right {
                return true
            }
        }else{
            if direction == MDCSwipeDirection.Left || direction == MDCSwipeDirection.Right || direction == MDCSwipeDirection.Up || direction == MDCSwipeDirection.Down {
                return true
            }
        }
        UIView.animateWithDuration(0.16, animations: { () -> Void in
            view.transform = CGAffineTransformIdentity
            var superView : UIView = self.view.superview!
            self.view.center = superView.convertPoint(superView.center, fromView: superView.superview)
        })
        return false
    }
    
    func view(view: UIView!, wasChosenWithDirection direction: MDCSwipeDirection) {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.boolForKey("instruction") {
            userDefaults.setBool(false, forKey: "instruction")
            self.searchBar.userInteractionEnabled = true
            self.refineButton.userInteractionEnabled = true
            self.menuBtn.userInteractionEnabled = true
            self.btnAddItem.userInteractionEnabled = true
            self.itemDetailTap.enabled = true
            self.revealViewController().panGestureRecognizer().enabled = true
            loadNext()
            return
        }
        
        switch direction {
        case MDCSwipeDirection.Left:
            let recordend = NSDate();
            self.recordtime = recordend.timeIntervalSinceDate(recordstart);
            Bakkle.sharedInstance.markItem("meh", item_id: self.item_id, duration: self.recordtime, success: {}, fail: {})
            loadNext()
            break
        case MDCSwipeDirection.Right:
            let recordend = NSDate();
            self.recordtime = recordend.timeIntervalSinceDate(recordstart);
            //Bakkle.updateduration(recordtime);
            //println(recordtime);
            /* Don't mark as want at first
            should mark item according what is selected on the start a chat screen */
            //            Bakkle.sharedInstance.markItem("want", item_id: self.item_id, success: {}, fail: {})
            self.itemData = Bakkle.sharedInstance.feedItems[0] as? NSDictionary
            
            // Ensure that the item isn't your own
            if ((self.itemData!.valueForKey("seller") as! NSDictionary).valueForKey("facebook_id") as! String) != Bakkle.sharedInstance.facebook_id_str {
                self.displayStartAChat(self.swipeView.imageView.image)
            } else {
                loadNext()
            }
            break
        case MDCSwipeDirection.Up:
            let recordend = NSDate();
            self.recordtime = recordend.timeIntervalSinceDate(recordstart);
            
            Bakkle.sharedInstance.markItem("hold", item_id: self.item_id, duration: self.recordtime, success: {}, fail: {})
            loadNext()
            break
        case MDCSwipeDirection.Down:
            let recordend = NSDate();
            recordtime = recordend.timeIntervalSinceDate(recordstart);
            //Bakkle.updateduration(recordtime);
            //println(recordtime);
            let alertController = UIAlertController(title: "Alert", message:"INPUT BELOW", preferredStyle: .Alert)
            var report: UITextField!
            let confirmAction = UIAlertAction(title: "Confirm", style: .Default, handler: { action in
                if report != nil {
                    println(report.text)
                    Bakkle.sharedInstance.markItem("report", item_id: self.item_id, message: report.text, duration: self.recordtime, success: {}, fail: {})
                } else {
                    Bakkle.sharedInstance.markItem("report", item_id: self.item_id, duration: self.recordtime,success: {}, fail: {})
                }
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
    
    @IBAction func highlightBorder(sender: UIButton) {
        sender.layer.borderColor = UIColor.darkGrayColor().CGColor
    }
    
    @IBAction func unhighlightBorder(sender: UIButton) {
        sender.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    // These are needed for drag in and out
    @IBAction func animateHighlightBorder(sender: UIButton) {
        UIView.animateWithDuration(0.75, animations: {
            sender.layer.borderColor = UIColor.darkGrayColor().CGColor
        })
    }
    
    @IBAction func animateUnhighlightBorder(sender: UIButton) {
        UIView.animateWithDuration(0.75, animations: {
            sender.layer.borderColor = UIColor.whiteColor().CGColor
        })
    }
    
    func displayStartAChat(image: UIImage?) {
        self.revealViewController().panGestureRecognizer().enabled = false
        self.btnAddItem.enabled = false
        self.searchBar.userInteractionEnabled = false
        self.refineButton.enabled = false
        self.menuBtn.enabled = false
        
        // Set the image, only request more data if we have to
        if image != nil {
            self.startChatItemImage.image = image
        } else {
            let imgURL = NSURL(string: (itemData!.valueForKey("image_urls") as! NSArray)[0] as! String)
            if imgURL != nil {
                let request: NSURLRequest = NSURLRequest(URL: imgURL!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        self.startChatItemImage.image = UIImage(data: data)
                    } else {
                        NSLog("%@", error)
                    }
                })
            }
        }
        
        if let x: AnyObject = itemData!.valueForKey("pk") {
            self.sendMessageButton.tag = Int(x.intValue)
            self.makeAnOfferButton.tag = Int(x.intValue)
        }
        
        self.view.bringSubviewToFront(self.startChatView)
        self.startChatView.hidden = false
        self.startChatView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(-M_PI_4))
        // this is the left side for some reason
        self.startChatViewOriginX.constant = -16
        self.startChatViewOriginY.constant = 0
        
        UIView.animateWithDuration(0.75, animations: { Void in
            self.startChatView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0)
            self.startChatView.layoutIfNeeded()
            }, completion: {Void in
                
        })
    }
    
    func closeStartAChat(state: MDCSwipeResult?) {
        self.sendMessageButton.tag = 0
        
        self.makeAnOfferButton.sendActionsForControlEvents(.TouchUpOutside)
        self.sendMessageButton.sendActionsForControlEvents(.TouchUpOutside)
        
        var destination = self.startChatView.frame
        var transformAngle: CGFloat = 0
        
        if let swipeResult = state {
            // This is used to find the direction that the user was swiping
            // Logic from: MDCSwipeOptions.m, MDCCGRectExtendedOutOfBounds
            while (!CGRectIsNull(CGRectIntersection(self.view.frame, destination))) {
                destination = CGRectMake(CGRectGetMinX(destination) + swipeResult.translation.x,
                    CGRectGetMinY(destination) + swipeResult.translation.y,
                    CGRectGetWidth(destination),
                    CGRectGetHeight(destination))
            }
        } else {
            destination.origin.x = self.startChatView.frame.width * 2
            destination.origin.y = 50
            transformAngle = CGFloat(M_PI_4)
        }
        
        self.startChatViewOriginX.constant = destination.origin.x
        self.startChatViewOriginY.constant = destination.origin.y
        
        self.btnAddItem.enabled = true
        self.searchBar.userInteractionEnabled = true
        self.refineButton.enabled = true
        self.menuBtn.enabled = true
        
        UIView.animateWithDuration(0.16, animations: { Void in
            self.startChatView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, transformAngle)
            self.startChatView.layoutIfNeeded()
            }, completion: {Void in
                self.revealViewController().panGestureRecognizer().enabled = true
                
                self.startChatView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(-M_PI_4))
                self.startChatViewOriginX.constant = self.startChatView.frame.width * -1
                self.startChatView.hidden = true
                self.darkenStartAChat.alpha = 0.0
                self.loadNext()
        })
    }
    
    @IBAction func sendMessage (sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if Bakkle.sharedInstance.account_type == Bakkle.bkAccountTypeGuest {
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            self.presentViewController(vc, animated: true, completion: nil)
            self.btnAddItem.enabled = true
            self.searchBar.userInteractionEnabled = true
            self.refineButton.enabled = true
            self.menuBtn.enabled = true
        }else{
            sender.layer.borderColor = UIColor.whiteColor().CGColor
            
            let buyer = User(facebookID: Bakkle.sharedInstance.facebook_id_str,accountID: Bakkle.sharedInstance.account_id,
                firstName: Bakkle.sharedInstance.first_name, lastName: Bakkle.sharedInstance.last_name)
            let account = Account(user: buyer)
            let chatItem = self.itemData!
            let chatItemId = String(sender.tag)
            var chatId: Int = 0
            var chatPayload: WSRequest = WSStartChatRequest(itemId: chatItemId)
            chatPayload.successHandler = {
                (var success: NSDictionary) in
                chatId = success.valueForKey("chatId") as! Int
                var buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chatId)
                let chatViewController = ChatViewController(chat: buyerChat)
                chatViewController.itemData = chatItem
                chatViewController.seller = chatItem.valueForKey("seller") as! NSDictionary
                chatViewController.isBuyer = true
                self.navigationController?.pushViewController(chatViewController, animated: true)
            }
            WSManager.enqueueWorkPayload(chatPayload)
            
            // mark as want
            Bakkle.sharedInstance.markItem("want", item_id: self.item_id, duration: self.recordtime,success: {}, fail: {})
            
            self.closeStartAChat(nil)
        }
    }
    
    @IBAction func makeAnOffer(sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if Bakkle.sharedInstance.account_type == 0 {
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            self.presentViewController(vc, animated: true, completion: nil)
            self.btnAddItem.enabled = true
            self.searchBar.userInteractionEnabled = true
            self.refineButton.enabled = true
            self.menuBtn.enabled = true
        }else{
            
            sender.layer.borderColor = UIColor.whiteColor().CGColor
            
            let buyer = User(facebookID: Bakkle.sharedInstance.facebook_id_str,accountID: Bakkle.sharedInstance.account_id,
                firstName: Bakkle.sharedInstance.first_name, lastName: Bakkle.sharedInstance.last_name)
            let account = Account(user: buyer)
            let chatItem = self.itemData!
            let chatItemId = String(sender.tag)
            var chatId: Int = 0
            var chatPayload: WSRequest = WSStartChatRequest(itemId: chatItemId)
            chatPayload.successHandler = {
                (var success: NSDictionary) in
                chatId = success.valueForKey("chatId") as! Int
                var buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chatId)
                let chatViewController = ChatViewController(chat: buyerChat)
                chatViewController.itemData = chatItem
                chatViewController.seller = chatItem.valueForKey("seller") as! NSDictionary
                chatViewController.isBuyer = true
                chatViewController.shouldProposeOffer = true
                self.navigationController?.pushViewController(chatViewController, animated: true)
            }
            WSManager.enqueueWorkPayload(chatPayload)
            
            // mark as want
            Bakkle.sharedInstance.markItem("want", item_id: self.item_id, duration: self.recordtime, success: {}, fail: {})
            
            self.closeStartAChat(nil)
        }
    }
    
    @IBAction func saveToWatchList(sender: AnyObject) {
        Bakkle.sharedInstance.markItem("hold", item_id: self.item_id, duration: self.recordtime, success: {}, fail: {})
        self.closeStartAChat(nil)
    }
    
    @IBAction func loginCheck(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if Bakkle.sharedInstance.checkPermission(Bakkle.bkPermissionAddItem) {
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
            let vc = sb.instantiateViewControllerWithIdentifier("CameraView") as! CameraView
            self.presentViewController(vc, animated: true, completion: nil)
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
