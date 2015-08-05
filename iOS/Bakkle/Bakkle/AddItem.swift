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

import FBSDKShareKit

class AddItem: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    static let KEYBOARD_MOVE_VALUE: CGFloat = 210
    static let NUMPAD_MOVE_VALUE:CGFloat = 260
    static let DESCRIPTION_PLACEHOLDER_COLOR = UIColor(red: CGFloat(AddItem.red)/255.0, green: CGFloat(AddItem.green)/255.0, blue: CGFloat(AddItem.blue)/255.0, alpha: CGFloat(1.0))
    static let BAKKLE_GREEN_COLOR = Theme.ColorGreen
    static let CONFIRM_BUTTON_DISABLED_COLOR = UIColor.lightGrayColor()
    private static let TAG_PLACEHOLDER_STR = "WORDS TO DESCRIBE ITEM"
    private static let red = 201
    private static let green = 201
    private static let blue = 201
    
    let albumName = "Bakkle"
    let listItemCellIdentifier = "ListItemCell"
    var itemImages: [UIImage]? = [UIImage]()
    var fileSizes: UInt64 = 0
    var item: NSDictionary!
    var isEditting: Bool = false
    var initRun = true
    var confirmHit = false
    var successfulAdd = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmButtonView: UIView!
    @IBOutlet weak var shareToFacebookBtn: UISwitch!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.hidden = true
        
        // set line border in the detail information container
        let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor = borderColor.CGColor
        priceView.layer.borderWidth = 1
        priceView.layer.borderColor = borderColor.CGColor
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = borderColor.CGColor
        shareView.layer.borderWidth = 1
        shareView.layer.borderColor = borderColor.CGColor
        
        // sets placeholder text in description textView
        textViewDidEndEditing(descriptionField)
        
        // -8.0 and -4.0 are y and x respectively, this is just to keep alignment of text
        // with the fields above it, because UITextView has different edges for scrolling
        descriptionField.contentInset = UIEdgeInsetsMake(-8.0, -5.0, 0, 0.0)
        
        var nextBtn = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        nextBtn.barStyle = UIBarStyle.Default
        nextBtn.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: nil, action: "priceNextToggle")]
        nextBtn.sizeToFit()
        priceField.inputAccessoryView = nextBtn
        
        // tap gesture recognizer for dismiss keyboard
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        titleField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        priceField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        setupButtons()
        
        let model = UIDevice.currentDevice().model
        if model == "iPad" {
            imageContainer.addConstraint(NSLayoutConstraint(item: imageContainer, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageContainer, attribute: NSLayoutAttribute.Height, multiplier: 2.0, constant: 0.0))
            self.collectionView.pagingEnabled = false
        }else{
            imageContainer.addConstraint(NSLayoutConstraint(item: imageContainer, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageContainer, attribute: NSLayoutAttribute.Height, multiplier: 1.5, constant: 0.0))
        }
    }
    
    
    func setupButtons() {
        closeBtn.setImage(IconImage().chevron(), forState: .Normal)
        closeBtn.setTitle("", forState: .Normal)
    }
    
    func priceNextToggle() {
        descriptionField.becomeFirstResponder()
    }
    
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
        animateViewMoving(true, moveValue: AddItem.KEYBOARD_MOVE_VALUE)
        if textView.textColor == AddItem.DESCRIPTION_PLACEHOLDER_COLOR {
            textView.textColor = UIColor.blackColor()
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = AddItem.DESCRIPTION_PLACEHOLDER_COLOR
            textView.text = AddItem.TAG_PLACEHOLDER_STR
        }
        
        animateViewMoving(false, moveValue: AddItem.KEYBOARD_MOVE_VALUE)
        
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
     * textFieldDidChange is called by titleField and priceField
     */
    func textFieldDidChange(textField: UITextField) {
        disableConfirmButtonHandler();
    }

    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == priceField {
            animateViewMoving(true, moveValue: AddItem.NUMPAD_MOVE_VALUE)
            if priceField.text == "take it!" {
                priceField.text = "0"
            }
        }else{
            animateViewMoving(true, moveValue: AddItem.KEYBOARD_MOVE_VALUE)
        }
    }
    
    /**
     * Handles disable / tag / formatting checks after user taps off of the field
     */
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == priceField {
            animateViewMoving(false, moveValue: AddItem.NUMPAD_MOVE_VALUE)
        }else{
            animateViewMoving(false, moveValue: AddItem.KEYBOARD_MOVE_VALUE)
        }
        formatPrice()
        disableConfirmButtonHandler()
    }
    
    // helper function to help screen move up or down
    func animateViewMoving(up: Bool, moveValue: CGFloat) {
        let movementDuration = 0.5
        let movement = up ? -moveValue : moveValue
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
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
                let tags = item.valueForKey("tags") as! String
                descriptionField.text = tags
                descriptionField.textColor = UIColor.blackColor()
            }
            confirmButton.setTitle("SAVE", forState: UIControlState.Normal)
    
            isEditting = false
        }
        disableConfirmButtonHandler()
    }
    
    func dismissKeyboard() {
        self.titleField.resignFirstResponder() || self.priceField.resignFirstResponder() || self.descriptionField.resignFirstResponder()
        disableConfirmButtonHandler()
    }

    @IBAction func cancelAdd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

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
        if confirmHit || trimString(self.priceField.text) == "$" || descriptionField.textColor == AddItem.DESCRIPTION_PLACEHOLDER_COLOR || self.titleField.text.isEmpty || self.priceField.text.isEmpty || self.descriptionField.text.isEmpty || itemImages?.count < 1 || itemImages?.count > CameraView.MAX_IMAGE_COUNT {
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
                priceField.text = String(format: "$ %.2f", value )
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
        self.view.bringSubviewToFront(self.loadingView)
        
        var time = NSDate.timeIntervalSinceReferenceDate()
        let item_id: NSInteger?
        if self.item != nil {
            item_id = self.item.valueForKey("pk") as? NSInteger
        } else {
            item_id = nil
        }
        Bakkle.sharedInstance.addItem(self.titleField.text, description: self.descriptionField.text, location: Bakkle.sharedInstance.user_location,
            price: self.priceField.text,
            images:self.itemImages!, item_id: item_id, success: {
                (item_id:Int?, image_url: String?) -> () in
                    time = NSDate.timeIntervalSinceReferenceDate() - time
                    println("Time taken to upload in sec: \(time)")
                    if self.shareToFacebookBtn.on {
//                        Adds the bakkle tag to the item, can't find anything about trying to use a local image for the url
//                        let topImg = UIImage(named: "pendant-tag660.png")
//                        let bottomImg = self.itemImages![0]
//                        let size = bottomImg.size
//                        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//                        bottomImg.drawInRect(CGRect(origin: CGPointZero, size: size))
//                        topImg!.drawInRect(CGRect(origin: CGPointZero, size: size))
//
//                        let newImg = UIGraphicsGetImageFromCurrentImageContext()
//                        UIGraphicsEndImageContext()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var content = FBSDKShareLinkContent()
                            content.contentDescription = self.descriptionField.text
                            content.contentTitle = self.titleField.text
                            
                            NSLog("Image URL: \(image_url)")
                            
                            /* FBSDK will not do anything if the url is invalid (no errors, just goes to feed) */
                            if Bakkle.sharedInstance.urlIsValid(image_url) {
                                content.imageURL = NSURL(string: image_url!)
                            }
                            
                            content.contentURL = NSURL(string: Bakkle.sharedInstance.getItemURL(item_id!))
                            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
                        })
                    }
                
                    // We just added one so schedule an update.
                    // TODO: Could just add this to the feed
                    // and hope we are fairly current.
                    Bakkle.sharedInstance.populateFeed({
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            println("item_id=\(item_id) item_url=\(image_url)")
                            self.successfulAdd = true
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    })
            }, fail: {() -> () in
                //TODO: Show error popup and close.
            })
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
    
    /**
     * This method trims a string
     */
    func trimString(str: String) -> (String) {
        return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }    
    
    /**
    * collectionView delegate and collectionView data source
    */
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
            cell.imgView.image = images[indexPath.row]
        }
        return cell
    }

}
