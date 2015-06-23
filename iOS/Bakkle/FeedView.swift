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

class FeedView: UIViewController, UIImagePickerControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate, MDCSwipeToChooseDelegate {
    
    var state : MDCPanState!
    let menuSegue = "presentNav"
    let addItemSegue = "AddItemSegue"
    let itemDetailSegue = "ItemDetailSegue"
    var searching = false
    
    let options = MDCSwipeToChooseViewOptions()
    var swipeView : MDCSwipeToChooseView!
    var bottomView : MDCSwipeToChooseView!
    
    private static let CAPTURE_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidCaptureItem"
    private static let REJECT_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidRejectItem"
    private static let DEVICE_MODEL: String = UIDevice.currentDevice().modelName
    var chosenImage: UIImage?
    var fromCamera: Bool! = false
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var noNewItemsLabel: UILabel!
    
    @IBOutlet weak var drawer: UIView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var instructionImgView: UIImageView!
    var blurImg: UIImageView!
    var closeBtn: UIButton!
    
    var hardCoded = false
    var itemDetailTap: UITapGestureRecognizer!
    
    var item_id = 42 //TODO: unhardcode this
    
    @IBOutlet weak var btnAddItem: UIButton!
    @IBOutlet weak var titleBar: UIView!
    
    
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
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Item detail tap
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
        setupButtons()
        for subview in self.searchBar.subviews {
            if (subview.isKindOfClass(UITextField)) {
                var searchField: UITextField = subview as! UITextField
                searchField.font = UIFont (name: "Avenir-Black", size: 12)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: FeedView.CAPTURE_NOTIFICATION_TEXT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: FeedView.REJECT_NOTIFICATION_TEXT, object: nil)

        
        // Insets set in Storyboard
        //btnAddItem.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        
        //TODO: Timer to check for new feed items
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        filterChanged()
        
        // Reset the swipeview if it is missing
        //        if self.swipeView == nil {
        resetSwipeView()
        //        }
        
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
        
        // Removed border around search bar.
        searchBar.barTintColor = titleBar.backgroundColor
        searchBar.layer.borderColor = titleBar.backgroundColor?.CGColor
        searchBar.layer.borderWidth = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // add instructional overlay for the first time usage
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.boolForKey("instruction") {
            // disable user interaction and show instruction
            self.itemDetailTap.enabled = false
            //self.constructInstructionView()
        }
    }
    
    // create the instruction image and show it on screen
    func constructInstructionView() {
        if self.swipeView != nil {
            var blur: UIVisualEffect! = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            var effectView: UIVisualEffectView = UIVisualEffectView(effect: blur)
            blurImg = UIImageView(frame: swipeView.frame)
            effectView.frame = blurImg.bounds
            blurImg.contentMode = UIViewContentMode.ScaleAspectFill
            blurImg.clipsToBounds = true
            blurImg.addSubview(effectView)

            instructionImgView = UIImageView(frame: swipeView.frame)
            instructionImgView.contentMode = UIViewContentMode.ScaleToFill
            instructionImgView.clipsToBounds = true
            instructionImgView.userInteractionEnabled = true
            instructionImgView.image = UIImage(named: "InstructionScreen.png")
            closeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            closeBtn.addTarget(self, action: "closeBtnPressed:", forControlEvents: .TouchUpInside)
            instructionImgView.addSubview(closeBtn)
            instructionImgView.userInteractionEnabled = true
            var mainWindow: UIWindow = UIApplication .sharedApplication().keyWindow!
            mainWindow.addSubview(blurImg)
            mainWindow.addSubview(instructionImgView)
        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.revealViewController().revealToggleAnimated(true)
        self.searchBar.resignFirstResponder()
        searching = false
        //TODO: remove this when feed is updated via push
        requestUpdates()
    }
    
    func closeBtnPressed(sender: UIButton!) {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setBool(false, forKey: "instruction")
        self.itemDetailTap.enabled = true
        instructionImgView.removeFromSuperview()
        blurImg.removeFromSuperview()
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
        else if (state != nil && state.direction != MDCSwipeDirection.None) {
            
            //if view is still on page, yet has been swiped in a direction, remove it.
            if self.swipeView != nil {
                self.swipeView.removeFromSuperview()
                self.swipeView = nil
            }
            
            //promote bottomView to prevent having to recreate swipeView
            self.swipeView = self.bottomView
            
            //create new bottomView
            self.bottomView = MDCSwipeToChooseView(frame: CGRectMake(self.swipeView.frame.origin.x, self.swipeView.frame.origin.y, self.swipeView.frame.width, self.swipeView.frame.height), options: nil)
            
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
                let location = topItem.valueForKey("location") as! String
                let topMethod = topItem.valueForKey("method") as! String
                
                if location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                    let start: CLLocation = CLLocation(locationString: location)
                    if let distance = Bakkle.sharedInstance.distanceTo(start) {
                        var distanceString = distance.rangeString()
                        self.swipeView.distLabel.attributedText = self.stringWithIcon(distanceString + " mi", image: IconImage().pin())
                    }
                }
                
                let sellersProfile = topItem.valueForKey("seller") as! NSDictionary
                let facebookID = sellersProfile.valueForKey("facebook_id") as! String
                let sellersName = sellersProfile.valueForKey("display_name") as! String
                var facebookProfileImgString = "http://graph.facebook.com/\(facebookID)/picture?width=142&height=142"
                
                //TODO: handle case where sellers name is null
                let dividedName = split(sellersName) {$0 == " "}
                
                let firstName = dividedName[0] as String
                let lastName = ""// String(Array(dividedName[1])[0])
                
                //println("[FeedScreen] Downloading image (top) \(imgURLs)")
                self.swipeView.nameLabel.text = topTitle
                
                var myString : String = ""
                if suffix(topPrice, 2) == "00" {
                    let withoutZeroes = "$\((topPrice as NSString).integerValue)"
                    myString = " " + withoutZeroes
                } else {
                    myString = " $" + topPrice
                }
                self.swipeView.priceLabel.attributedText = self.stringWithIcon(myString, image: IconImage().tags())
                
                if swipeView.imageView.image == nil {
                    self.swipeView.imageView.image = UIImage(named: "loading.png")
                    self.swipeView.userInteractionEnabled = false
                }
                
                self.swipeView.methodLabel.attributedText = self.stringWithIcon(topMethod, image: IconImage().car())
                
                self.swipeView.sellerName.text = firstName // + " " + lastName + "."
                self.swipeView.ratingView.rating = 3.5
                        let firstURL = imgURLs[0] as! String
                        let imgURL = NSURL(string: firstURL)
                        let profileImgURL = NSURL(string: facebookProfileImgString)
                            //println("[FeedScreen] displaying image (top)")
                            if imgURL == nil {
                                
                            }else{
                                self.swipeView.bottomBlurImg.hnk_setImageFromURL(imgURL!)
                                self.swipeView.imageView.hnk_setImageFromURL(imgURL!)
                                self.swipeView.userInteractionEnabled = true
                                println("IMAGE WIDTH AND HEIGHT ARE: \(self.swipeView.imageView.image?.size.width), \(self.swipeView.imageView.image?.size.height)")
                                self.swipeView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                                println("FACEBOOK PROFILE LINK IS: \(facebookProfileImgString)")
                                self.swipeView.profileImg.image = UIImage(data: NSData(contentsOfURL: profileImgURL!)!)
                                
                                println("IMAGE FRAME WIDTH AND HEIGHT ARE: \(self.swipeView.imageView.frame.size.width), \(self.swipeView.imageView.frame.size.height)")
                            }
                            super.view.addSubview(self.swipeView)
                        
                        if Bakkle.sharedInstance.feedItems.count > 1 {
                            if self.bottomView != nil {
                                self.bottomView.alpha = 1
                                
                                var bottomItem = Bakkle.sharedInstance.feedItems[1]
                                let bottomURLs = bottomItem.valueForKey("image_urls") as! NSArray
                                let bottomTitle: String = bottomItem.valueForKey("title") as! String
                                let bottomPrice: String = bottomItem.valueForKey("price") as! String
                                let bottomMethod = topItem.valueForKey("method") as! String
                                
                                let sellersProfile = bottomItem.valueForKey("seller") as! NSDictionary
                                let facebookID = sellersProfile.valueForKey("facebook_id") as! String
                                let sellersName = sellersProfile.valueForKey("display_name") as! String
                                let location = bottomItem.valueForKey("location") as! String
                                var facebookProfileImgString = "http://graph.facebook.com/\(facebookID)/picture?width=142&height=142"
                                
                                let dividedName = split(sellersName) {$0 == " "}
                                
                                let firstName = dividedName[0] as String
                                let lastName = "" //String(Array(dividedName[1])[0])
                                
                                if location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                                    let start: CLLocation = CLLocation(locationString: location)
                                    if let distance = Bakkle.sharedInstance.distanceTo(start) {
                                        var distanceString = distance.rangeString()
                                        self.bottomView.distLabel.attributedText = self.stringWithIcon(distanceString + " mi", image: IconImage().pin())
                                    }
                                }
                                
                                self.bottomView.userInteractionEnabled = false
                                
                                //println("[FeedScreen] Downloading image (bottom) \(bottomURLs)")
                                let bottomURL = bottomURLs[0] as! String
                                let imgURL = NSURL(string: bottomURL)
                                let profileImgURL = NSURL(string: facebookProfileImgString)
                                    //println("[FeedScreen] displaying image (bottom)")
                                    if let x = imgURL {
                                        self.bottomView.bottomBlurImg.hnk_setImageFromURL(imgURL!)
                                        self.bottomView.imageView.hnk_setImageFromURL(imgURL!)
                                        self.bottomView.profileImg.image = UIImage(data: NSData(contentsOfURL: profileImgURL!)!)
                                        
                                        self.bottomView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                                    }
                                    
                                    var myString : String = ""
                                    if suffix(bottomPrice, 2) == "00" {
                                        let withoutZeroes = "$\((bottomPrice as NSString).integerValue)"
                                        myString = " " + withoutZeroes
                                    } else {
                                        myString = " $" + bottomPrice
                                    }
                                    self.bottomView.priceLabel.attributedText = self.stringWithIcon(myString, image: IconImage().tags())

                                    self.bottomView.nameLabel.text = bottomTitle
                                    
                                    self.bottomView.methodLabel.attributedText = self.stringWithIcon(bottomMethod, image: IconImage().car())
                                    
                                    self.bottomView.sellerName.text = firstName // + " " + lastName + "."
                                    self.bottomView.ratingView.rating = 3.5
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
    
    func stringWithIcon(label: String, image: UIImage) -> NSAttributedString {
        var attachment: OffsetTextAttachment = OffsetTextAttachment()
        let font: UIFont = self.swipeView.distLabel.font
        attachment.fontDescender = font.descender
        attachment.image = image
        
        var attachmentString : NSAttributedString = NSAttributedString(attachment: attachment)
        var stringFinal : NSMutableAttributedString = NSMutableAttributedString(string: " " + label)
        stringFinal.insertAttributedString(attachmentString, atIndex: 0)
        
        return stringFinal
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
    }
    
    
    /* Camera */
    let albumName = "Bakkle"
    
    func showAddItem(){
        var addItem: UIViewController = AddItem()
        presentViewController(addItem, animated: true, completion: nil)
    }
    
    var imagePicker = UIImagePickerController()
    
    // Display camera as first step of add-item
    @IBAction func cameraBtn(sender: AnyObject) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            
            drawCameraOverlay(false)
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            fromCamera = true
            
        } else{
            //no camera available
            var alert = UIAlertController(title: "Sorry", message: "Bakkle requires a picture when selling items", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(false, completion: nil)
                
                /* This allows us to test add item without camera on simulator */
                if UIDevice.currentDevice().model == "iPhone Simulator" {
                    self.chosenImage = UIImage(named: "tiger.jpg")
                    self.performSegueWithIdentifier(self.addItemSegue, sender: self)
                }
                
            }))
            self.presentViewController(alert, animated: false, completion: nil)
        }
    }
    
    /**
    * This function either defaults as the initial camera overlay
    */
    func drawCameraOverlay(retakeView: Bool) {
        // firstChange is value is the only value recorded while watching firstChange in AddItem during testing
        let firstChange: CGFloat = 20.0
        let screenSize = UIScreen.mainScreen().bounds
        let imgWidth = screenSize.width < screenSize.height ? screenSize.width : screenSize.height
        let newStatusBarHeight: CGFloat
        let pickerFrame: CGRect
        let squareFrame: CGRect
        
        var adjust = imagePicker.view.bounds.height - imagePicker.navigationBar.bounds.size.height - imagePicker.toolbar.bounds.size.height
        if retakeView {
            newStatusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            pickerFrame = CGRectMake(0, 0, imagePicker.view.bounds.width, adjust + AddItem.frameHeightAdjust[FeedView.DEVICE_MODEL]!)
            squareFrame = CGRectMake(pickerFrame.width/2 - imgWidth/2, adjust/2 - imgWidth/2 + firstChange + AddItem.retakeFrameAdjust[FeedView.DEVICE_MODEL]!, imgWidth, imgWidth)
        } else {
            // 20.0 is the default height of the toolbar near the origin
            pickerFrame = CGRectMake(0, 20.0, imagePicker.view.bounds.width, adjust - AddItem.frameHeightAdjust[FeedView.DEVICE_MODEL]!)
            squareFrame = CGRectMake(pickerFrame.width/2 - imgWidth/2, adjust/2 - imgWidth/2 - AddItem.captureFrameAdjust[FeedView.DEVICE_MODEL]!, imgWidth, imgWidth)
        }
        
        UIGraphicsBeginImageContext(pickerFrame.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextClearRect(context, screenSize)
        
        CGContextSaveGState(context)
        CGContextAddRect(context, CGContextGetClipBoundingBox(context))
        CGContextMoveToPoint(context, squareFrame.origin.x, squareFrame.origin.y)
        CGContextAddLineToPoint(context, squareFrame.origin.x + squareFrame.width, squareFrame.origin.y)
        CGContextAddLineToPoint(context, squareFrame.origin.x + squareFrame.width, squareFrame.origin.y + squareFrame.size.height)
        CGContextAddLineToPoint(context, squareFrame.origin.x, squareFrame.origin.y + squareFrame.size.height)
        CGContextAddLineToPoint(context, squareFrame.origin.x, squareFrame.origin.y)
        CGContextEOClip(context)
        CGContextMoveToPoint(context, pickerFrame.origin.x, pickerFrame.origin.y)
        CGContextSetRGBFillColor(context, 0, 0, 0, 1)
        CGContextFillRect(context, pickerFrame)
        
        CGContextRestoreGState(context)
        let overlayImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        let overlayView = UIImageView(frame: pickerFrame)
        overlayView.image = overlayImage
        self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.imagePicker.cameraOverlayView = overlayView
    }
    
    func handleNotification(message: NSNotification) {
        if message.name == FeedView.CAPTURE_NOTIFICATION_TEXT {
            drawCameraOverlay(true)
        } else if message.name == FeedView.REJECT_NOTIFICATION_TEXT {
            drawCameraOverlay(false)
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
            destinationVC.itemImages?.insert(self.chosenImage!, atIndex: 0)
            
            // Scaled image size
            let scaledImageWidth: CGFloat = 660.0;
            var size = CGSize(width: scaledImageWidth, height: scaledImageWidth)
            dispatch_async(dispatch_get_global_queue(
                Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                    self.chosenImage!.cropAndResize(size, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
                        destinationVC.scaledImages?.insert(resizedImage, atIndex: 0)
                    })
            }
        }
        if segue.identifier == self.itemDetailSegue {
            let destinationVC = segue.destinationViewController as! ItemDetails
            
            destinationVC.item = Bakkle.sharedInstance.feedItems[0] as! NSDictionary
        }
    }
}
