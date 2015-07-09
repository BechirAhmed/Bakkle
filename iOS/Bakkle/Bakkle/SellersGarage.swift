//
//  SellersGarage.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Photos
import Haneke

class SellersGarageView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let garageCellIdentifier = "GarageCell"
    
    private static let CAPTURE_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidCaptureItem"
    private static let REJECT_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidRejectItem"
    private static let DEVICE_MODEL: String = UIDevice.currentDevice().modelName
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var chosenImage: UIImage?
    let addItemSegue = "AddItemSegueFromGarage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: SellersGarageView.CAPTURE_NOTIFICATION_TEXT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: SellersGarageView.REJECT_NOTIFICATION_TEXT, object: nil)
        
        setupButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Register for garage updates
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkGarageUpdate, object: nil, queue: mainQueue) { _ in
            println("Received garage update")
            self.refreshData()
        }

        requestUpdates()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    /* New data arrived, update the garage on screen */
    func refreshData() {
        Bakkle.sharedInstance.info("Refreshing sellers garage items")
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    /* Request update from server */
    func requestUpdates() {
        println("[Sellers Garage] Requesting updates from server")
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            Bakkle.sharedInstance.populateGarage({})
        }
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.revealViewController().revealToggleAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Bakkle.sharedInstance.garageItems != nil ? Bakkle.sharedInstance.garageItems.count : 0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(100.0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : GarageCell = tableView.dequeueReusableCellWithIdentifier(self.garageCellIdentifier, forIndexPath: indexPath) as! GarageCell
        
        // Load image
        if Bakkle.sharedInstance.garageItems != nil {
            cell.setCornerRadius()
            
            let item = Bakkle.sharedInstance.garageItems[indexPath.row]
            let imgURLs = item.valueForKey("image_urls") as! NSArray
            
            let firstURL = imgURLs[0] as! String
            let imgURL = NSURL(string: firstURL)
            cell.imgView.hnk_setImageFromURL(imgURL!)
            cell.imgView.layer.cornerRadius = 10.0
            cell.imageView?.clipsToBounds = true
            cell.background.layer.cornerRadius = 10.0
            
            cell.nameLabel.text = item.valueForKey("title") as? String
            
            let topPrice: String = item.valueForKey("price") as! String
            var myString : String = ""
            if suffix(topPrice, 2) == "00" {
                let withoutZeroes = "$\((topPrice as NSString).integerValue)"
                myString = withoutZeroes
            } else {
                myString = "$" + topPrice
            }
            cell.priceLabel.text = myString
            
            cell.numHold.text = (item.valueForKey("number_of_holding") as! NSNumber).stringValue
            cell.holdView.layer.cornerRadius = 15.0
            
            cell.numLike.text = (item.valueForKey("number_of_want") as! NSNumber).stringValue
            cell.likeView.layer.cornerRadius = 15.0
            
            cell.numNope.text = (item.valueForKey("number_of_meh") as! NSNumber).stringValue
            cell.nopeView.layer.cornerRadius = 15.0
            
            cell.numViews.text = (item.valueForKey("number_of_views") as! NSNumber).stringValue
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chatsViewController = ChatsViewController()
        chatsViewController.chatItemID = (Bakkle.sharedInstance.garageItems[indexPath.row].valueForKey("pk") as! NSNumber).stringValue
        chatsViewController.garageIndex = indexPath.row
        self.navigationController?.pushViewController(chatsViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = Bakkle.sharedInstance.garageItems[indexPath.row] as! NSDictionary
            Bakkle.sharedInstance.removeItem(item.valueForKey("pk")!.integerValue, success: {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    Bakkle.sharedInstance.garageItems.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                })
            }, fail: {})
            
        }
    }

    
    /* Camera */
    let albumName = "Bakkle"
    
    var imagePicker = UIImagePickerController()
    
    // Display camera as first step of add-item
    @IBAction func btnAddItem(sender: AnyObject) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            drawCameraOverlay(false)
            self.presentViewController(imagePicker, animated: false, completion: nil)
            
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
            pickerFrame = CGRectMake(0, 0, imagePicker.view.bounds.width, adjust + AddItem.frameHeightAdjust[SellersGarageView.DEVICE_MODEL]!)
            squareFrame = CGRectMake(pickerFrame.width/2 - imgWidth/2, adjust/2 - imgWidth/2 + firstChange + AddItem.retakeFrameAdjust[SellersGarageView.DEVICE_MODEL]!, imgWidth, imgWidth)
        } else {
            // 20.0 is the default height for the tool bar near the origin
            pickerFrame = CGRectMake(0, 20.0, imagePicker.view.bounds.width, adjust - AddItem.frameHeightAdjust[SellersGarageView.DEVICE_MODEL]!)
            squareFrame = CGRectMake(pickerFrame.width/2 - imgWidth/2, adjust/2 - imgWidth/2 - AddItem.captureFrameAdjust[SellersGarageView.DEVICE_MODEL]!, imgWidth, imgWidth)
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
        if message.name == SellersGarageView.CAPTURE_NOTIFICATION_TEXT {
            drawCameraOverlay(true)
        } else if message.name == SellersGarageView.REJECT_NOTIFICATION_TEXT {
            drawCameraOverlay(false)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
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
                        let compressedImage = UIImageJPEGRepresentation(resizedImage, AddItem.JPEG_COMPRESSION_CONSTANT)
                        destinationVC.itemImages?[0] = UIImage(data:compressedImage)!
                        destinationVC.scaledImages?.insert(compressedImage, atIndex: 0)
                    })
            }
        }
    }
    
}
