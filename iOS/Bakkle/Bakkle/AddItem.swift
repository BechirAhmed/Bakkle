//
//  AddItem.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//
//  Edited by Patrick Barr 6/4/15.

import UIKit
import Photos
import Social

//import FBSDKCoreKit
//import FBSDKShareKit
//import FBSDKLoginKit

class AddItem: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    let albumName = "Bakkle"
    
    var itemImage: UIImage?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var tagsField: UITextView!
    @IBOutlet weak var methodControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmButtonText: UILabel!
    @IBOutlet weak var confirmButtonView: UIView!
    @IBOutlet weak var shareToFacebookBtn: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.delegate = self
        priceField.delegate = self
        tagsField.delegate = self
        
        // sets placeholder text
        textViewDidEndEditing(tagsField)
        
        // -8.0 and -4.0 are y and x respectively, this is just to keep alignment of text
        // with the fields above it, because UITextView has different edges for scrolling
        tagsField.contentInset = UIEdgeInsetsMake(-8.0, -5.0, 0, 0.0)
        
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
        
        // There is an odd bug with button text on this call, see
        // disableConfirmButtonHandler() documentation for more information
        if !initRun {
            disableConfirmButtonHandler()
        } else {
            initRun = false
        }
    }
    
    /**
     * This func limits the characters in the title, a check was needed to stop other fields from
     * this limitation.
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return textField == titleField ? (count(textField.text.utf16) + count(string.utf16) - range.length) <= 30 : true
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
        confirmButton.enabled = false
        if self.itemImage != nil {
            imageView.image = self.itemImage!
        } else {
            /* This allows us to test adding image using simulator */
            if UIDevice.currentDevice().model == "iPhone Simulator" {
                imageView.image = UIImage(named: "tiger.jpg")
            } else {
                imageView.image = UIImage(named: "blank.png")
            }
        }
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
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
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
        disableConfirmButtonHandler()
        
    }

    @IBAction func cancelAdd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    static let CONFIRM_BUTTON_RED = 51
    static let CONFIRM_BUTTON_GREEN = 205
    static let CONFIRM_BUTTON_BLUE = 95
    static let CONFIRM_BUTTON_ENABLED_COLOR = UIColor(red: CGFloat(AddItem.CONFIRM_BUTTON_RED)/255.0, green: CGFloat(AddItem.CONFIRM_BUTTON_GREEN)/255.0, blue: CGFloat(AddItem.CONFIRM_BUTTON_BLUE)/255.0, alpha: CGFloat(1.0))
    static let CONFIRM_BUTTON_DISABLED_COLOR = UIColor.lightGrayColor()
    
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
    func disableConfirmButtonHandler() -> Bool{
        if tagsField.textColor == AddItem.TAG_PLACEHOLDER_COLOR || self.titleField.text.isEmpty || self.priceField.text.isEmpty || self.tagsField.text.isEmpty || imageView.image == nil {
            confirmButton.enabled = false
            confirmButton.backgroundColor = AddItem.CONFIRM_BUTTON_DISABLED_COLOR
        } else {
            confirmButton.enabled = true
            confirmButton.backgroundColor = AddItem.CONFIRM_BUTTON_ENABLED_COLOR
        }
        confirmButtonView.bringSubviewToFront(confirmButtonText)
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
        self.methodControl.enabled = false
        
        confirmButton.enabled = false
        confirmButton.backgroundColor = AddItem.CONFIRM_BUTTON_DISABLED_COLOR
        confirmButtonView.bringSubviewToFront(confirmButtonText)
        
        var activityView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        //TODO: Get location from GPS
        var factor: CGFloat = 1.0 //imageView.image!.size.height/imageView.image!.size.width
        
        //Scale image to improve transfer speeds 950 is good iphone 6+ size. ip5=640px wide, ip6=750 ip6+=1242
        let scaledImageWidth: CGFloat = 660.0;
        
        var size = CGSize(width: scaledImageWidth, height: scaledImageWidth*factor)
        imageView.image!.cropToSquare({(croppedImg:UIImage,cropBob:NSData) -> () in

            croppedImg.resize(size, completionHandler: {(scaledImg:UIImage,scaleBob:NSData) -> () in

                
                Bakkle.sharedInstance.addItem(self.titleField.text, description: "", location: Bakkle.sharedInstance.user_location, price: self.priceField.text, tags: self.tagsField.text, method: self.methodControl.titleForSegmentAtIndex(self.methodControl.selectedSegmentIndex)!, images:[scaledImg], success: {(item_id:Int?, item_url: String?) -> () in
                    
                    if self.shareToFacebookBtn.on {
                        let topImg = UIImage(named: "pendant-tag660.png")
                        let bottomImg = scaledImg
                        let size = scaledImg.size
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
                    
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    
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
                    }
                    }, fail: {() -> () in
                        //TODO: Show error popup and close.
                })
                
            })
        })
    }
    
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
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
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
    
    let commonWords: Set<NSString> = ["the", "of", "and", "a", "to", "in", "is", "you", "that", "it", "he", "was", "for", "on", "are", "as", "with", "his", "they", "i", "at", "be", "this", "have", "from", "or", "one", "had", "by", "but", "not", "what", "all", "were", "we", "when", "your", "can", "said", "there", "use", "an", "each", "which", "she", "do", "how", "their", "if", "will", "up", "other", "about", "out", "many", "then", "them", "these", "so", "some", "her"," would", "make", "like", "him", "into", "has", "look", "more", "write", "go", "see", "no", "way", "could", "people", "my", "than", "first", "been", "call", "who","its","now","find","down","day","did","get","come","made","may","part", "another", "any", "anybody", "anyone", "anything", "both", "either", "everybody", "everyone", "everything", "am"]
    
    var oldGeneratedTags = ""
    
    /**
     * This generates tags if the last generation of tags is the same as the current tag field
     * This is only called AFTER the title updates. The check is so that it doesn't overwrite
     * any user added tags
     */
    func populateTagsFromTitle(fullTitle: String) {
        var generatedTags = generateTags(fullTitle)
        
        // the lines before and after the statement make simulate a user accessing the text field
        textViewDidBeginEditing(tagsField)
        if tagsField.text == oldGeneratedTags || tagsField.text == AddItem.TAG_PLACEHOLDER_STR || tagsField.textColor == AddItem.TAG_PLACEHOLDER_COLOR {
            tagsField.text = generatedTags
        }
        textViewDidEndEditing(tagsField)
        
        oldGeneratedTags = generatedTags
    }
    
    /**
     * Generates tags from the title text:
     * Splits title text into pices by spaces / punctuation
     * Iterates through the array and makes sure there aren't any duplicate words
     * Turns the list of words into a string and returns it
     * Performance should not be a large issue due to the character limit on title
     */
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
            if !tagList.contains(tag) {
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
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = chosen
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* FACEBOOK */
    func postOnWall() {
        var conn: FBRequestConnection = FBRequestConnection()
//        var handler: FBRequestHandler = conn
        
        var postString: String = "\(titleField.text) \(tagsField.text))"

       // if FBSession
        
    }
    
    
//    
//    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
//    [[[FBSDKGraphRequest alloc]
//    initWithGraphPath:@"me/feed"
//    parameters: @{ @"message" : @"hello world"}
//    HTTPMethod:@"POST"]
//    startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//    if (!error) {
//    NSLog(@"Post id:%@", result[@"id"]);
//    }
//    }];
//    }
    
    
//- (void)postOnWall
//{
//NSNumber *testMessageIndex=[[NSNumber alloc] init];
//if ([[NSUserDefaults standardUserDefaults] objectForKey:@"testMessageIndex"]==nil)
//{
//testMessageIndex=[NSNumber numberWithInt:100];
//}
//else
//{
//testMessageIndex=[[NSUserDefaults standardUserDefaults] objectForKey:@"testMessageIndex"];
//};
//testMessageIndex=[NSNumber numberWithInt:[testMessageIndex intValue]+1];
//[[NSUserDefaults standardUserDefaults] setObject:testMessageIndex forKey:@"testMessageIndex"];
//[[NSUserDefaults standardUserDefaults] synchronize];
//
//// create the connection object
//FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
//
//// create a handler block to handle the results of the request for fbid's profile
//FBRequestHandler handler =
//^(FBRequestConnection *connection, id result, NSError *error) {
//// output the results of the request
//[self requestCompleted:connection forFbID:@"me" result:result error:error];
//};
//
//// create the request object, using the fbid as the graph path
//// as an alternative the request* static methods of the FBRequest class could
//// be used to fetch common requests, such as /me and /me/friends
//NSString *messageString=[NSString stringWithFormat:@"wk test message %i", [testMessageIndex intValue]];
//FBRequest *request=[[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me/feed" parameters:[NSDictionary dictionaryWithObject:messageString forKey:@"message"] HTTPMethod:@"POST"];
//
//// add the request to the connection object, if more than one request is added
//// the connection object will compose the requests as a batch request; whether or
//// not the request is a batch or a singleton, the handler behavior is the same,
//// allowing the application to be dynamic in regards to whether a single or multiple
//// requests are occuring
//[newConnection addRequest:request completionHandler:handler];
//
//// if there's an outstanding connection, just cancel
//[self.requestConnection cancel];
//
//// keep track of our connection, and start it
//self.requestConnection = newConnection;
//[newConnection start];
//}
//
//// FBSample logic
//// Report any results.  Invoked once for each request we make.
//- (void)requestCompleted:(FBRequestConnection *)connection
//forFbID:fbID
//result:(id)result
//error:(NSError *)error
//{
//NSLog(@"request completed");
//
//// not the completion we were looking for...
//if (self.requestConnection &&
//connection != self.requestConnection)
//{
//NSLog(@"    not the completion we are looking for");
//return;
//}
//
//// clean this up, for posterity
//self.requestConnection = nil;
//
//if (error)
//{
//NSLog(@"    error");
//UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//// error contains details about why the request failed
//[alert show];
//}
//else
//{
//NSLog(@"   ok");
//};
//}

}
