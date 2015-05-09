//
//  AddItem.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import Photos

class AddItem: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let albumName = "Bakkle"
    
    var itemImage: UIImage?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var methodField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.delegate = self
        priceField.delegate = self
        tagsField.delegate = self
        methodField.delegate = self
        
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
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 235)
        formatPrice()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 235)
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
        methodField.text = "Pick-up"
    }
    
    func dismissKeyboard() {
        self.titleField.resignFirstResponder() || self.priceField.resignFirstResponder() || self.tagsField.resignFirstResponder() || self.methodField.resignFirstResponder()
        validateTextFields()
    }

    @IBAction func cancelAdd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func validateTextFields() {
        if self.titleField.text.isEmpty || self.priceField.text.isEmpty || self.tagsField.text.isEmpty || self.methodField.text.isEmpty || imageView.image == nil {
            add.enabled = false
        }
        else {
            add.enabled = true
        }
    }
    
    @IBOutlet weak var add: UIButton!    
    
    func formatPrice() {
        if (priceField.text as String).lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            priceField.text = String(format: "%.2f", (priceField.text! as NSString).floatValue )
        }
    }
    @IBAction func btnAdd(sender: AnyObject) {
        self.titleField.enabled = false
        self.priceField.enabled = false
        self.tagsField.enabled = false
        self.methodField.enabled = false
        add.enabled = false
        
        var activityView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        //TODO: Add drop down 'Pick-up', 'Delivery', 'Meet', 'Ship'
        //TODO: Get location from GPS
        var factor = imageView.image!.size.height/imageView.image!.size.width
        var size = CGSize(width: 1100, height: 1100*factor)
        imageView.image!.resize(size, completionHandler: {(scaledImg:UIImage,bob:NSData) -> () in
            
            Bakkle.sharedInstance.addItem(self.titleField.text, description: "", location: Bakkle.sharedInstance.user_location, price: self.priceField.text, tags: self.tagsField.text, method: /*self.methodField.text*/"Pick-up", image:scaledImg, success: {

                activityView.stopAnimating()
                activityView.removeFromSuperview()
                
                // We just added one so schedule an update.
                // TODO: Could just add this to the feed
                // and hope we are fairly current.
                dispatch_async(dispatch_get_main_queue()) {
                    Bakkle.sharedInstance.populateFeed({})
                    
                    let alertController = UIAlertController(title: "Bakkle", message:
                        "Item uploaded to Bakkle.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let dismissAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alertController.addAction(dismissAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            } /* TODO: Fail, warn*/)
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == titleField {
            priceField.becomeFirstResponder()
        }
        else if textField == tagsField {
            methodField.becomeFirstResponder()
        }
        else if textField == priceField {
            tagsField.becomeFirstResponder()
        }
        else if textField == methodField {
            methodField.resignFirstResponder()
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosen = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = chosen
        dismissViewControllerAnimated(true, completion: nil)
    }

}
