//
//  AddItem.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//
//  Edited by Patrick Barr 6/2/15.

import UIKit
import Photos
import Social

//import FBSDKCoreKit
//import FBSDKShareKit
//import FBSDKLoginKit

class AddItem: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let albumName = "Bakkle"
    let listItemCellIdentifier = "ListItemCell"
    var itemImages: [UIImage]?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var methodControl: UISegmentedControl!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var camButtonBackground: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var shareToFacebookBtn: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.delegate = self
        priceField.delegate = self
        tagsField.delegate = self
        
        camButtonBackground.layer.cornerRadius = camButtonBackground.frame.size.width/2
        
        var nextBtn = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        nextBtn.barStyle = UIBarStyle.Default
        nextBtn.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: nil, action: "priceNextToggle")]
        nextBtn.sizeToFit()
        priceField.inputAccessoryView = nextBtn
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        titleField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func priceNextToggle() {
        tagsField.becomeFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return (count(textField.text.utf16) + count(string.utf16) - range.length) <= 30
    }
    
    func textFieldDidChange(textField: UITextField) {
        populateTagsFromTitle(textField.text);
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 215)
        formatPrice()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == priceField {
            animateViewMoving(false, moveValue: 30)
        }
        animateViewMoving(false, moveValue: 215)
        formatPrice()
        validateTextFields()
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
        add.enabled = false
        
        // Set default
        methodControl.selectedSegmentIndex = 0;
    }
    
    @IBAction func beginEditingPrice(sender: AnyObject) {
        animateViewMoving(true, moveValue: 30)
        if priceField.text == "take it!" {
            priceField.text = "0"
            println("setting to zero")
        }
    }
    func dismissKeyboard() {
        self.titleField.resignFirstResponder() || self.priceField.resignFirstResponder() || self.tagsField.resignFirstResponder()
        validateTextFields()
        
    }

    @IBAction func cancelAdd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func validateTextFields() {
        if self.titleField.text.isEmpty || self.priceField.text.isEmpty || self.tagsField.text.isEmpty || self.itemImages == nil {
            add.enabled = false
        }
        else {
            add.enabled = true
        }
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
        // TODO (bug ID #36 don't post if Title > 30 characters, then alert the user saying "Title must be no longer than 30 characters."
        // Array(titleField.text) to get the characters separated into an array, then check length
        
        self.titleField.enabled = false
        self.priceField.enabled = false
        self.tagsField.enabled = false
        self.methodControl.enabled = false
        add.enabled = false
        
        var activityView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        //TODO: Add drop down 'Pick-up', 'Delivery', 'Meet', 'Ship'
        //TODO: Get location from GPS
        var factor: CGFloat = 1.0 //imageView.image!.size.height/imageView.image!.size.width
        
        //Scale image to improve transfer speeds 950 is good iphone 6+ size. ip5=640px wide, ip6=750 ip6+=1242
        let scaledImageWidth: CGFloat = 660.0;
        
        var size = CGSize(width: scaledImageWidth, height: scaledImageWidth*factor)
        if let images = self.itemImages {
            for image in images {
                image.cropToSquare({(croppedImg:UIImage,cropBob:NSData) -> () in
                    croppedImg.resize(size, completionHandler: {(scaledImg:UIImage,scaleBob:NSData) -> () in
                        // add item call
                    })
                })
            }
        }
    }
    
//    Bakkle.sharedInstance.addItem(self.titleField.text, description: "", location: Bakkle.sharedInstance.user_location, price: self.priceField.text, tags: self.tagsField.text, method: self.methodControl.titleForSegmentAtIndex(self.methodControl.selectedSegmentIndex)!, image:scaledImg, success: {(item_id:Int?, item_url: String?) -> () in
//    
//    if self.shareToFacebookBtn.on {
//    let topImg = UIImage(named: "pendant-tag660.png")
//    let bottomImg = scaledImg
//    let size = scaledImg.size
//    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//    bottomImg.drawInRect(CGRect(origin: CGPointZero, size: size))
//    topImg!.drawInRect(CGRect(origin: CGPointZero, size: size))
//    
//    let newImg = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    
//    var photo: FBSDKSharePhoto! = FBSDKSharePhoto()
//    photo.image = newImg
//    photo.userGenerated = true
//    
//    var cont: FBSDKSharePhotoContent! = FBSDKSharePhotoContent()
//    cont.photos = [photo]
//    
//    var dialog: FBSDKShareDialog = FBSDKShareDialog.showFromViewController(self, withContent: cont, delegate: nil)
//    
//    }
//    
//    activityView.stopAnimating()
//    activityView.removeFromSuperview()
//    
//    // We just added one so schedule an update.
//    // TODO: Could just add this to the feed
//    // and hope we are fairly current.
//    dispatch_async(dispatch_get_main_queue()) {
//    Bakkle.sharedInstance.populateFeed({})
//    
//    println("item_id=\(item_id) item_url=\(item_url)")
//    
//    let alertController = UIAlertController(title: "Bakkle", message:
//    "Item uploaded to Bakkle.", preferredStyle: UIAlertControllerStyle.Alert)
//    
//    let dismissAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) { (action) -> Void in
//    self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    alertController.addAction(dismissAction)
//    self.presentViewController(alertController, animated: true, completion: nil)
//    }
//    }, fail: {() -> () in
//    //TODO: Show error popup and close.
//    })
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == titleField {
            priceField.becomeFirstResponder()
        }
        else if textField == priceField {
           tagsField.becomeFirstResponder()
        }
        else if textField == tagsField {
            tagsField.resignFirstResponder()
        }
        return true
    }
    

    @IBAction func cameraBtn(sender: AnyObject) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
            
        } else{
            //no camera available
            var alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    let commonWords: Set<NSString> = ["the","of","and","a","to","in","is","you","that","it","he","was","for","on","are","as","with","his","they","i","at","be","this","have","from","or","one","had","by","word","but","not","what","all","were","we","when","your","can","said","there","use","an","each","which","she","do","how","their","if","will","up","other","about","out","many","then","them","these","so","some","her","would","make","like","him","into","time","has","look","two","more","write","go","see","number","no","way","could","people","my","than","first","water","been","call","who","its","now","find","long","down","day","did","get","come","made","may","part", "another", "any", "anybody", "anyone", "anything","both","either", "everybody", "everyone", "everything", "am"]
    
    var oldGeneratedTags = ""
    
    func populateTagsFromTitle(fullTitle: String) {
        var generatedTags = generateTags(fullTitle)
        if tagsField.text == oldGeneratedTags {
            tagsField.text = generatedTags
            oldGeneratedTags = generatedTags
            return
        }
    }
    
    func generateTags(fullTitle: String) -> String {
        var titleFieldText = trimString(fullTitle.uppercaseString)
        var tagList: Set<String> = Set<String>()
        
        titleFieldText = titleFieldText.stringByReplacingOccurrencesOfString(".", withString: " ")
        titleFieldText = titleFieldText.stringByReplacingOccurrencesOfString(",", withString: " ")
        titleFieldText = titleFieldText.stringByReplacingOccurrencesOfString(";", withString: " ")
        titleFieldText = titleFieldText.stringByReplacingOccurrencesOfString("  ", withString: " ")
        
        var titleWords = split(titleFieldText) {$0 == " "}
        var tagOrder = [String]()
        
        var index = 0
        for tag in titleWords {
            if(!tagList.contains(tag)) {
                tagOrder.append(tag)
                tagList.insert(tag)
            }
            index++
        }
        
        var tagFieldText = ""
        for tag in tagOrder {
            if !commonWords.contains(tag.lowercaseString) {
                tagFieldText = tagFieldText +  " \(tag),"
            }
        }
        
        var size = count(tagFieldText) - 1
        if size > 0 && Array(tagFieldText)[size] == "," {
            tagFieldText = tagFieldText.substringToIndex(advance(tagFieldText.startIndex, count(tagFieldText) - 1))
        }
        
        return trimString(tagFieldText)
    }
    
    /**
     * This is just a short way to trim a string, return and variable may change to NSString if current code doesn't work
     */
    func trimString(str: String) -> (String) {
        return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosen = info[UIImagePickerControllerOriginalImage] as! UIImage
//        imageView.contentMode = UIViewContentMode.ScaleAspectFill
//        imageView.image = chosen
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* FACEBOOK */
    func postOnWall() {
        var conn: FBRequestConnection = FBRequestConnection()
        var postString: String = "\(titleField.text) \(tagsField.text))"
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        //return self.itemImages!.count
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let screenHeight = CGRectGetHeight(collectionView.bounds)
        return CGSize(width: screenHeight, height: screenHeight)
    }
    
//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//            return 2
//    }
//    
//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//            return 2
//    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ListItemCell = collectionView.dequeueReusableCellWithReuseIdentifier(listItemCellIdentifier, forIndexPath: indexPath) as! ListItemCell
        cell.backgroundColor = UIColor.redColor()
//        cell.imgView.contentMode = UIViewContentMode.ScaleAspectFill
//        cell.imgView.clipsToBounds  = true
//        if let images = self.itemImages {
//            if images.count != 0 {
//                cell.imgView.image = images[indexPath.row]
//            } else {
//                /* This allows us to test adding image using simulator */
//                if UIDevice.currentDevice().model == "iPhone Simulator" {
//                    cell.imgView.image = UIImage(named: "tiger.jpg")
//                } else {
//                    cell.imgView.image = UIImage(named: "blank.png")
//                }
//            }
//        }
        
        
        
        /* Temporary hack for developing to speed testing of add-item */
        //        if Bakkle.sharedInstance.facebook_id == 686426858203 {
        //            var formatter: NSDateFormatter = NSDateFormatter()
        //            formatter.dateFormat = "MM-dd-HH-mm-ss"
        //            let dateTimePrefix: String = formatter.stringFromDate(NSDate())
        //            titleField.text = "Tiger \(dateTimePrefix)"
        //            priceField.text = "34000.00"
        //            tagsField.text = "tiger predator dictator-loot"
        //            self.validateTextFields()
        //            add.enabled = true
        //        }
        
//        cell.contentMode = UIViewContentMode.ScaleAspectFill
//        cell.imgView.image = UIImage(named: "blank.png")!
//        
//        // Load image
//        if Bakkle.sharedInstance.garageItems != nil {
//            let item = Bakkle.sharedInstance.garageItems[indexPath.row]
//            let imgURLs = item.valueForKey("image_urls") as! NSArray
//            
//            let firstURL = imgURLs[0] as! String
//            let imgURL = NSURL(string: firstURL)
//            cell.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.imgView.hnk_setImageFromURL(imgURL!)
//        }
        
        return cell
    }

}
