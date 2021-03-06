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

class AddItem: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let albumName = "Bakkle"
    
    var itemImage: UIImage?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var methodControl: UISegmentedControl!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var shareToFacebookBtn: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.delegate = self
        priceField.delegate = self
        tagsField.delegate = self
        
        var nextBtn = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        nextBtn.barStyle = UIBarStyle.Default
        nextBtn.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: nil, action: "priceNextToggle")]
        nextBtn.sizeToFit()
        priceField.inputAccessoryView = nextBtn
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
    }
    
    func priceNextToggle() {
        tagsField.becomeFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        validateTextFields()
        if textField == titleField {
            populateTagsFromTitle()
        }
        return true
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
        validateTextFields()
        
    }

    @IBAction func cancelAdd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func validateTextFields() {
        if self.titleField.text.isEmpty || self.priceField.text.isEmpty || self.tagsField.text.isEmpty || imageView.image == nil {
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
        imageView.image!.cropToSquare({(croppedImg:UIImage,cropBob:NSData) -> () in

            croppedImg.resize(size, completionHandler: {(scaledImg:UIImage,scaleBob:NSData) -> () in

                
                Bakkle.sharedInstance.addItem(self.titleField.text, description: "", location: Bakkle.sharedInstance.user_location, price: self.priceField.text, tags: self.tagsField.text, method: self.methodControl.titleForSegmentAtIndex(self.methodControl.selectedSegmentIndex)!, image:scaledImg, success: {(item_id:Int?, item_url: String?) -> () in
                    
                    if self.shareToFacebookBtn.enabled {
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

    // TODO: Rewrie this so it removes punctuation and some symbols, splits the phrase into an array, then searches the array
    // for unwanted common words, then puts into tags field
    let commonWords = ["the","of","and","a","to","in","is","you","that","it","he","was","for","on","are","as","with","his","they","I","at","be","this","have","from","or","one","had","by","word","but","not","what","all","were","we","when","your","can","said","there","use","an","each","which","she","do","how","their","if","will","up","other","about","out","many","then","them","these","so","some","her","would","make","like","him","into","time","has","look","two","more","write","go","see","number","no","way","could","people","my","than","first","water","been","call","who","oil","its","now","find","long","down","day","did","get","come","made","may","part"]
    func populateTagsFromTitle() {
        if titleField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            var tags: NSString = (titleField.text as NSString)
            tags = tags.stringByReplacingOccurrencesOfString(".", withString: "")
            tags = tags.stringByReplacingOccurrencesOfString(",", withString: "")
            tags = tags.stringByReplacingOccurrencesOfString(";", withString: "")
            for word in commonWords {
                tags = tags.stringByReplacingOccurrencesOfString(word, withString: "")
            }
            if tagsField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 ||
                tags.substringToIndex(tags.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)-1) == tagsField.text {
                    tagsField.text = tags as String
            }
        }
        println(tagsToHashTags(tagsField.text))
    }

    //TODO run the above sanitizer first, then split and hashtag
    func tagsToHashTags(tags: String) -> (String) {
        var tagsArr = split(tags) {$0 == " "}
        let hashTags = tagsArr.reduce("") {
            a, b in
            let comma = (b == tagsArr.last) ? "" : ", "
            return "#\(a)\(b)\(comma)"
        }
        return hashTags
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
        
        var postString: String = "\(titleField.text) \(tagsToHashTags(tagsField.text))"

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
