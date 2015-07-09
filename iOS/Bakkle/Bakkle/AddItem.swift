//
//  AddItem.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import Photos
import Social


//import FBSDKCoreKit
//import FBSDKShareKit
//import FBSDKLoginKit

class AddItem: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    let albumName = "Bakkle"
    
    static let JPEG_COMPRESSION_CONSTANT: CGFloat = 0.3
    static let MAX_IMAGE_COUNT = 5
    static let SCALED_IMAGES_READY_NOTIFICATION = "SCALED_IMAGES_READY"
    
    
    private static let CAPTURE_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidCaptureItem"
    private static let REJECT_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidRejectItem"
    private static let DEVICE_MODEL: String = UIDevice.currentDevice().modelName
    
    let listItemCellIdentifier = "ListItemCell"
    var itemImages: [UIImage]? = [UIImage]()
    var scaledImages: [NSData]? = [NSData]()
    var fileSizes: UInt64 = 0
    var item: NSDictionary!
    var isEditting: Bool = false
    var KEYBOARD_MOVE_VALUE: CGFloat = 250
    var NUMPAD_MOVE_VALUE:CGFloat = 260
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmButtonView: UIView!
    @IBOutlet weak var shareToFacebookBtn: UISwitch!
    @IBOutlet weak var camButtonBackground: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
   
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var shareView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.delegate = self
        priceField.delegate = self
        descriptionField.delegate = self
        
        loadingView.hidden = true
        
        // set line border
        let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor = borderColor.CGColor
        priceView.layer.borderWidth = 1
        priceView.layer.borderColor = borderColor.CGColor
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = borderColor.CGColor
        shareView.layer.borderWidth = 1
        shareView.layer.borderColor = borderColor.CGColor
        
        // sets placeholder text
        textViewDidEndEditing(descriptionField)
        
        // set camera button
        camButtonBackground.layer.cornerRadius = camButtonBackground.frame.size.width/2
        camButtonBackground.setNeedsDisplay()
        
        // -8.0 and -4.0 are y and x respectively, this is just to keep alignment of text
        // with the fields above it, because UITextView has different edges for scrolling
        descriptionField.contentInset = UIEdgeInsetsMake(-8.0, -5.0, 0, 0.0)
        
        var nextBtn = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        nextBtn.barStyle = UIBarStyle.Default
        nextBtn.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: nil, action: "priceNextToggle")]
        nextBtn.sizeToFit()
        priceField.inputAccessoryView = nextBtn
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        titleField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        priceField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: AddItem.CAPTURE_NOTIFICATION_TEXT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: AddItem.REJECT_NOTIFICATION_TEXT, object: nil)
        
        
        setupButtons()
    }
    
    
    func setupButtons() {
        closeBtn.setImage(IconImage().close(), forState: .Normal)
        closeBtn.setTitle("", forState: .Normal)
    }
    
    func priceNextToggle() {
        descriptionField.becomeFirstResponder()
    }
    
    static let TAG_PLACEHOLDER_STR = "5 WORDS TO DESCRIBE ITEM"
    static let red = 201
    static let green = 201
    static let blue = 201
    static let TAG_PLACEHOLDER_COLOR = UIColor(red: CGFloat(AddItem.red)/255.0, green: CGFloat(AddItem.green)/255.0, blue: CGFloat(AddItem.blue)/255.0, alpha: CGFloat(1.0))
    
    /**
     * UITextView does not have placeholder text, the next 2 functions implement a placeholder
     *
     * ********************************* IMPORTANT ***********************************
     *  TO CHANGE THE TEXT OF tagsView WITH CODE, YOU HAVE TO SIMULATE A USER EDITING
     *  THE FIELD BY CALLING textViewDidBeginEditing(tagsView) AND END BY CALLING THE
     *   FUNCTION textViewDidEndEditing(tagsView) (mainly for tag population checks)
     * *******************************************************************************
     */
    func textViewDidBeginEditing(textView: UITextView) {
        animateViewMoving(true, moveValue: KEYBOARD_MOVE_VALUE)
        if textView.textColor == AddItem.TAG_PLACEHOLDER_COLOR {
            textView.textColor = UIColor.blackColor()
            textView.text = ""
        }
    }
    
    var initRun = true
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = AddItem.TAG_PLACEHOLDER_COLOR
            textView.text = AddItem.TAG_PLACEHOLDER_STR
        }
        
        animateViewMoving(false, moveValue: KEYBOARD_MOVE_VALUE)
        
        // There is an odd bug with button text on this call, see
        // disableConfirmButtonHandler() documentation for more information
        if !initRun {
            disableConfirmButtonHandler()
        } else {
            initRun = false
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        disableConfirmButtonHandler()
    }
    
    /**
     * This func limits the characters in the title, a check was needed to stop other fields from
     * this limitation.
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return textField == titleField ? (count(textField.text.utf16) + count(string.utf16) - range.length) <= 30 : true
    }
    
    /**
     * textFieldDidChange is called by titleField and priceField, specific cases for each
     */
    func textFieldDidChange(textField: UITextField) {
        disableConfirmButtonHandler();
    }

    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == priceField {
            animateViewMoving(true, moveValue: NUMPAD_MOVE_VALUE)
        }else{
            animateViewMoving(true, moveValue: KEYBOARD_MOVE_VALUE)
        }
        formatPrice()
    }
    
    /**
     * Handles disable / tag / formatting checks after user taps off of the field
     */
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == priceField {
            animateViewMoving(false, moveValue: NUMPAD_MOVE_VALUE)
        }else{
            animateViewMoving(false, moveValue: KEYBOARD_MOVE_VALUE)
        }
        formatPrice()
        disableConfirmButtonHandler()
    }
    
    func animateViewMoving(up: Bool, moveValue: CGFloat) {
        let movementDuration = 0.5
        let movement = up ? -moveValue : moveValue
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    /* Currently, not using it. Might use it in future. */
    func keboardWillShow(notification: NSNotification) {
        var info: NSDictionary = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        var keyboardHeight: CGFloat = keyboardFrame.height
        
        var animationDuration: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.view.frame = CGRectMake(0, self.view.frame.origin.y - keyboardHeight, self.view.bounds.width, self.view.bounds.height)
        }, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        // set content if it's in edit mode
        if isEditting {
            titleLabel.text = "EDIT ITEM"
            titleField.text = item.valueForKey("title") as! String
            priceField.text = item.valueForKey("price") as! String
            formatPrice()
            let description = item.valueForKey("description") as! String
            if description != "" {
                descriptionField.text = description as String
                descriptionField.textColor = UIColor.blackColor()
            }else{
                let tags = item.valueForKey("tags") as! Array<String>
                descriptionField.text = ", ".join(tags)
                descriptionField.textColor = UIColor.blackColor()
            }
            confirmButton.setTitle("SAVE", forState: UIControlState.Normal)
            let imageUrls = item.valueForKey("image_urls") as! Array<String>
            for index in 0...imageUrls.count-1 {
                var imageURL: NSURL = NSURL(string: imageUrls[index])!
                var imageData: NSData = NSData(contentsOfURL: imageURL)!
                itemImages?.append(UIImage(data: imageData)!)
                scaledImages?.append(imageData)
            }
            isEditting = false
        }
        disableConfirmButtonHandler()

    }
    
    @IBAction func beginEditingPrice(sender: AnyObject) {
        animateViewMoving(true, moveValue: KEYBOARD_MOVE_VALUE)
        if priceField.text == "take it!" {
            priceField.text = "0"
        }
    }
    
    func dismissKeyboard() {
        self.titleField.resignFirstResponder() || self.priceField.resignFirstResponder() || self.descriptionField.resignFirstResponder()
        disableConfirmButtonHandler()
    }

    @IBAction func cancelAdd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    static let CONFIRM_BUTTON_RED = 51
    static let CONFIRM_BUTTON_GREEN = 205
    static let CONFIRM_BUTTON_BLUE = 95
    static let BAKKLE_GREEN_COLOR = UIColor(red: CGFloat(AddItem.CONFIRM_BUTTON_RED)/255.0, green: CGFloat(AddItem.CONFIRM_BUTTON_GREEN)/255.0, blue: CGFloat(AddItem.CONFIRM_BUTTON_BLUE)/255.0, alpha: CGFloat(1.0))
    static let CONFIRM_BUTTON_DISABLED_COLOR = UIColor.lightGrayColor()
    var confirmHit = false
    
    /**
    * @return Bool: true if confirm button is enabled
    *
    * This handles disabling and enabling the confirm button (changing color, etc).
    * Updating the backgroundColor end up placing the confirmButtonText behind the
    * button itself, so it needs to be brought back infront.
    *
    * Note: for some reason, if the background is changed before the first frame of
    * this page is shown, the text will not be brought to the front until this function
    * is called again.
    *
    * Note 2: To fix the initialization of the above note, the button is initialized as
    * disabled and gray, the RGB color on the three variables above CONFIRM_BUTTON_RED,
    * CONFIRM_BUTTON_GREEN, CONFIRM_BUTTON_BLUE will need to be changed if the color is
    * ever to be changed
    */
    func disableConfirmButtonHandler() -> Bool {
        if confirmHit || trimString(self.priceField.text) == "$" || descriptionField.textColor == AddItem.TAG_PLACEHOLDER_COLOR || self.titleField.text.isEmpty || self.priceField.text.isEmpty || self.descriptionField.text.isEmpty || itemImages?.count < 1 || itemImages?.count > AddItem.MAX_IMAGE_COUNT {
            confirmButton.enabled = false
            confirmButton.backgroundColor = AddItem.CONFIRM_BUTTON_DISABLED_COLOR
        } else {
            confirmButton.enabled = true
            confirmButton.backgroundColor = AddItem.BAKKLE_GREEN_COLOR
        }
        return confirmButton.enabled
    }
    
    func formatPrice() {
        if (priceField.text as String).lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            var str = (priceField.text! as NSString).stringByReplacingOccurrencesOfString("$", withString: "")
            str = str.stringByReplacingOccurrencesOfString(" ", withString: "")
            var value:Float = (str as NSString).floatValue
            // Currently capping value at 100k
            if value > 100000 {
                value = 100000
            }
            if value == 0 {
                priceField.text = "take it!"
            } else {
                priceField.text = String(format: "$ %.2f", (str as NSString).floatValue )
            }
        }
    }
    
    @IBAction func btnConfirm(sender: AnyObject) {
        self.titleField.enabled = false
        self.priceField.enabled = false
        self.descriptionField.editable = false
        
        confirmHit = true
        
        confirmButton.enabled = false
        confirmButton.backgroundColor = AddItem.CONFIRM_BUTTON_DISABLED_COLOR
        
        self.loadingView.hidden = false
        
        //TODO: Get location from GPS
        var factor: CGFloat = 1.0 //imageView.image!.size.height/imageView.image!.size.width
        
        if scaledImages?.count == itemImages?.count {
            var time = NSDate.timeIntervalSinceReferenceDate()
            let item_id: NSInteger?
            if self.item != nil {
                item_id = self.item.valueForKey("pk") as? NSInteger
            } else {
                item_id = nil
            }
            Bakkle.sharedInstance.addItem(self.titleField.text, description: self.descriptionField.text, location: Bakkle.sharedInstance.user_location,
                price: self.priceField.text,
                images:self.scaledImages!, item_id: item_id, success: {
                    (item_id:Int?, item_url: String?) -> () in
                        time = NSDate.timeIntervalSinceReferenceDate() - time
                        println("Time taken to upload in sec: \(time)")
                        if self.shareToFacebookBtn.on {
                            let topImg = UIImage(named: "pendant-tag660.png")
                            let bottomImg = UIImage(data:self.scaledImages![0])!
                            let size = bottomImg.size
                            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                            bottomImg.drawInRect(CGRect(origin: CGPointZero, size: size))
                            topImg!.drawInRect(CGRect(origin: CGPointZero, size: size))

                            let newImg = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()

                            var photo: FBSDKSharePhoto! = FBSDKSharePhoto()
                            photo.image = newImg
                            photo.userGenerated = true

                            var cont: FBSDKSharePhotoContent! = FBSDKSharePhotoContent()
                            cont.photos = [photo]

                            var dialog: FBSDKShareDialog = FBSDKShareDialog.showFromViewController(self, withContent: cont, delegate: nil)
                        }
                    
                    
                        // We just added one so schedule an update.
                        // TODO: Could just add this to the feed
                        // and hope we are fairly current.
                        dispatch_async(dispatch_get_main_queue()) {
                            Bakkle.sharedInstance.populateFeed({})
                            println("item_id=\(item_id) item_url=\(item_url)")

                            let alertController = UIAlertController(title: "Bakkle", message:
                                "Item uploaded to Bakkle.", preferredStyle: UIAlertControllerStyle.Alert)

                            let dismissAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) { (action) -> Void in
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                            alertController.addAction(dismissAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }                    }, fail: {() -> () in
                    //TODO: Show error popup and close.
                })
        } else {
            println("[LIST ITEM] Error: All images were not included in scaled images.")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == titleField {
            priceField.becomeFirstResponder()
        }
        else if textField == priceField {
           descriptionField.becomeFirstResponder()
        }
        else if textField == descriptionField {
            descriptionField.resignFirstResponder()
        }
        return true
    }
    
    var imagePicker = UIImagePickerController()
    internal static let frameHeightAdjust  = ["iPhone 5"      : CGFloat(20.0), // Confirmed
                                             "iPhone 5S"     : CGFloat(20.0),
                                             "iPhone 5C"     : CGFloat(20.0),
                                             "iPhone 6"      : CGFloat(20.0), // Confirmed
                                             "iPhone 6 Plus" : CGFloat(22.0), // Confirmed
                                             "iPad 2"        : CGFloat(20.0),
                                             "iPad 3"        : CGFloat(20.0),
                                             "iPad 4"        : CGFloat( 0.0), // testing -> needs a lot of work
                                             "iPad Air"      : CGFloat(20.0),
                                             "iPad Air 2"    : CGFloat(20.0),
                                             "iPad Mini"     : CGFloat(20.0),
                                             "iPad Mini 2"   : CGFloat(20.0),
                                             "iPod Touch 5"  : CGFloat(20.0)]
    
    internal static let retakeFrameAdjust = ["iPhone 5"      : CGFloat(22.0), // Confirmed
                                             "iPhone 5S"     : CGFloat( 0.0),
                                             "iPhone 5C"     : CGFloat( 0.0),
                                             "iPhone 6"      : CGFloat(20.0), // Confirmed
                                             "iPhone 6 Plus" : CGFloat(20.0), // Confirmed
                                             "iPad 2"        : CGFloat(20.0),
                                             "iPad 3"        : CGFloat(20.0),
                                             "iPad 4"        : CGFloat( 0.0), // testing -> needs a lot of work
                                             "iPad Air"      : CGFloat(20.0),
                                             "iPad Air 2"    : CGFloat(20.0),
                                             "iPad Mini"     : CGFloat(20.0),
                                             "iPad Mini 2"   : CGFloat(20.0),
                                             "iPod Touch 5"  : CGFloat(20.0)]
    
    internal static let captureFrameAdjust = ["iPhone 5"      : CGFloat( 4.0), // Confirmed
                                             "iPhone 5S"     : CGFloat( 0.0),
                                             "iPhone 5C"     : CGFloat( 0.0),
                                             "iPhone 6"      : CGFloat( 0.0), // Confirmed
                                             "iPhone 6 Plus" : CGFloat(26.0), // Confirmed
                                             "iPad 2"        : CGFloat(20.0),
                                             "iPad 3"        : CGFloat(20.0),
                                             "iPad 4"        : CGFloat( 0.0), // testing -> needs a lot of work
                                             "iPad Air"      : CGFloat(20.0),
                                             "iPad Air 2"    : CGFloat(20.0),
                                             "iPad Mini"     : CGFloat(20.0),
                                             "iPad Mini 2"   : CGFloat(20.0),
                                             "iPod Touch 5"  : CGFloat(20.0)]
    
    
    @IBAction func cameraBtn(sender: AnyObject) {
        if itemImages!.count >= AddItem.MAX_IMAGE_COUNT {
            var alert = UIAlertController(title: "Image Limit Reached", message: "You cannot add more than \(AddItem.MAX_IMAGE_COUNT) images.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            drawCameraOverlay()
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else{
            //no camera available
            var alert = UIAlertController(title: "Error", message: "There is no camera available.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private static var firstChange: CGFloat?
    private static var statusBarHeight = UIScreen.mainScreen().bounds.height
    private static var dontChangeBar = false
    
    func drawCameraOverlay() {
        drawCameraOverlay(false)
    }
    
    
    /**
     * This function either defaults as the initial camera overlay
     */
    func drawCameraOverlay(retakeView: Bool) {
        let screenSize = UIScreen.mainScreen().bounds
        let imgWidth = screenSize.width < screenSize.height ? screenSize.width : screenSize.height
        
        if !AddItem.dontChangeBar {
            AddItem.statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            AddItem.dontChangeBar = true
        }
        
        let newStatusBarHeight: CGFloat
        let pickerFrame: CGRect
        let squareFrame: CGRect
        var adjust = imagePicker.view.bounds.height - imagePicker.navigationBar.bounds.size.height - imagePicker.toolbar.bounds.size.height
        
        if retakeView {
            newStatusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            // temp, as soon as the dictionary is complete this can be removed
            if AddItem.firstChange == nil {
                AddItem.firstChange = abs(AddItem.statusBarHeight - newStatusBarHeight)
            }
            
            pickerFrame = CGRectMake(0, 0, imagePicker.view.bounds.width, adjust + AddItem.frameHeightAdjust[AddItem.DEVICE_MODEL]!)
            squareFrame = CGRectMake(pickerFrame.width/2 - imgWidth/2, adjust/2 - imgWidth/2 + AddItem.firstChange! + AddItem.retakeFrameAdjust[AddItem.DEVICE_MODEL]!, imgWidth, imgWidth)
        } else {
            // 20.0 is the default height for the menu near the origin of the canvas
            pickerFrame = CGRectMake(0, 20.0, imagePicker.view.bounds.width, adjust - AddItem.frameHeightAdjust[AddItem.DEVICE_MODEL]!)
            squareFrame = CGRectMake(pickerFrame.width/2 - imgWidth/2, adjust/2 - imgWidth/2 - AddItem.captureFrameAdjust[AddItem.DEVICE_MODEL]!, imgWidth, imgWidth)
        }
        
        var galleryButtonIcon = IconImage().gallery()
        var galleryButton: UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        galleryButton.frame = CGRectMake(screenSize.width - (imagePicker.navigationBar.bounds.size.height/2 + galleryButtonIcon.size.width), screenSize.height - (imagePicker.navigationBar.bounds.size.height/2 + galleryButtonIcon.size.height), galleryButtonIcon.size.width, galleryButtonIcon.size.height)
        galleryButton.setImage(galleryButtonIcon, forState: .Normal)
        galleryButton.setTitle("", forState: .Normal)
        galleryButton.addTarget(self, action: "changeImagePickerSourceType:", forControlEvents: UIControlEvents.TouchUpInside)
        galleryButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        galleryButton.setTitleColor(UIColor.lightGrayColor(), forState: .Selected)
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
        
        let squareOverlayView = UIImageView(frame: pickerFrame)
        squareOverlayView.image = overlayImage
        
        if !retakeView && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            imagePicker.cameraOverlayView?.addSubview(squareOverlayView)
            imagePicker.cameraOverlayView?.addSubview(galleryButton)
        } else {
            imagePicker.cameraOverlayView = squareOverlayView
        }
    }
    
    func handleNotification(message: NSNotification) {
        if message.name == AddItem.CAPTURE_NOTIFICATION_TEXT {
            drawCameraOverlay(true)
        } else if message.name == AddItem.REJECT_NOTIFICATION_TEXT {
            drawCameraOverlay()
        }
    }
    
    func changeImagePickerSourceType(sender: AnyObject) {
        if imagePicker.sourceType == UIImagePickerControllerSourceType.Camera {
            //imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.dismissViewControllerAnimated(false, completion: {
                self.imagePicker = UIImagePickerController()
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            })
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            drawCameraOverlay()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosen = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.itemImages?.append(chosen)
        var itemIndex: Int?
        for i in 0...(itemImages!.count - 1) {
            if itemImages![i] == chosen {
                itemIndex = i;
                break;
            }
        }
        
        // Scaled image size
        let scaledImageWidth: CGFloat = 660.0;
        var size = CGSize(width: scaledImageWidth, height: scaledImageWidth)
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                chosen.cropAndResize(size, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
                    var compressedImage = UIImageJPEGRepresentation(resizedImage, AddItem.JPEG_COMPRESSION_CONSTANT)
                    self.itemImages?[itemIndex!] = UIImage(data: compressedImage)!
                    var index: NSIndexPath = NSIndexPath(forRow: itemIndex!, inSection: 0)
                    self.collectionView.insertItemsAtIndexPaths([index])
                    self.scaledImages?.insert(compressedImage, atIndex: itemIndex!)
                    self.fileSizes = 0
                    for i in self.scaledImages! {
                        self.fileSizes += UInt64(i.length)
                    }
                    println("Image \(itemIndex! + 1) bit count: \(compressedImage.length) b")
                    println("Total image size bit count: \(self.fileSizes) b")
                })
                
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * This method trims a string
     */
    func trimString(str: String) -> (String) {
        return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    
    /* FACEBOOK */
    func postOnWall() {
        var conn: FBRequestConnection = FBRequestConnection()
//        var handler: FBRequestHandler = conn
        
        var postString: String = "\(titleField.text) \(descriptionField.text))"

       // if FBSession
        
    }
    
    
    /* collectionView display multiple pictures */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return self.itemImages!.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let screenHeight = CGRectGetHeight(collectionView.bounds)
        return CGSize(width: screenHeight, height: screenHeight)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 5
    }
   
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ListItemCell = collectionView.dequeueReusableCellWithReuseIdentifier(listItemCellIdentifier, forIndexPath: indexPath) as! ListItemCell
        cell.imgView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.imgView.clipsToBounds  = true
        if let images = self.itemImages {
            /* This allows us to test adding image using simulator */
            if UIDevice.currentDevice().model == "iPhone Simulator" && !isEditting{
                cell.imgView.image = UIImage(named: "tiger.jpg")
            } else {
                cell.imgView.image = images[indexPath.row]
            }
        }
        return cell
    }

}
