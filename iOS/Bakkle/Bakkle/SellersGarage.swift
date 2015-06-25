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

class SellersGarageView: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let garageCellIdentifier = "GarageCell"
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var assetThumbnailSize: CGSize!
    
    private static let CAPTURE_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidCaptureItem"
    private static let REJECT_NOTIFICATION_TEXT = "_UIImagePickerControllerUserDidRejectItem"
    private static let DEVICE_MODEL: String = UIDevice.currentDevice().modelName
    
    @IBOutlet weak var menuBtn: UIButton!
    var chosenImage: UIImage?
    let addItemSegue = "AddItemSegueFromGarage"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.collectionView.contentMode = UIViewContentMode.ScaleAspectFill
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: SellersGarageView.CAPTURE_NOTIFICATION_TEXT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: SellersGarageView.REJECT_NOTIFICATION_TEXT, object: nil)
        setupButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let scale: CGFloat = UIScreen.mainScreen().scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
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
            self.collectionView.reloadData()
        }
    }
    
    /* Request update from server */
    func requestUpdates() {
        println("[Sellers Garage] Requesting updates from server")
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            Bakkle.sharedInstance.populateGarage({})
        }
    }
    
    func updateView(collectionView: UICollectionView) {
        println("[Sellers Garage] Updating View")
        if Bakkle.sharedInstance.garageItems.count > 0 {
        }
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.revealViewController().revealToggleAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return Bakkle.sharedInstance.garageItems != nil ? Bakkle.sharedInstance.garageItems.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var screenWidth = CGRectGetWidth(collectionView.bounds)
        var cellWidth = screenWidth
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 2
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 2
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : GarageCell = collectionView.dequeueReusableCellWithReuseIdentifier(garageCellIdentifier, forIndexPath: indexPath) as! GarageCell
        cell.contentMode = UIViewContentMode.ScaleAspectFill
        cell.setThumbnailImage(UIImage(named: "blank.png")!)
        //        populateCells(cell)
//        collectionView.reloadData()
        
        // Load image
        if Bakkle.sharedInstance.garageItems != nil {
            let item = Bakkle.sharedInstance.garageItems[indexPath.row]
            let imgURLs = item.valueForKey("image_urls") as! NSArray
            
            let firstURL = imgURLs[0] as! String
            let imgURL = NSURL(string: firstURL)
            cell.contentMode = UIViewContentMode.ScaleAspectFill
            cell.imgView.hnk_setImageFromURL(imgURL!)

            cell.numHold.text = (item.valueForKey("number_of_holding") as! NSNumber).stringValue
            cell.numHold.layer.masksToBounds = true;
            cell.numHold.layer.cornerRadius = cell.numHold.frame.height/2
            
            cell.numLike.text = (item.valueForKey("number_of_want") as! NSNumber).stringValue
            cell.numLike.layer.masksToBounds = true;
            cell.numLike.layer.cornerRadius = cell.numLike.frame.height/2
            
            cell.numNope.text = (item.valueForKey("number_of_meh") as! NSNumber).stringValue
            cell.numNope.layer.masksToBounds = true;
            cell.numNope.layer.cornerRadius = cell.numNope.frame.height/2

            cell.numComment.text = (item.valueForKey("number_of_report") as! NSNumber).stringValue
            cell.numComment.layer.masksToBounds = true;
            cell.numComment.layer.cornerRadius = cell.numComment.frame.height/2
            
            cell.numViews.text = (item.valueForKey("number_of_views") as! NSNumber).stringValue

        }
        return cell
    }
    
    func populateCells(cell: GarageCell) {
        if Bakkle.sharedInstance.garageItems.count > 0 {
            let topItem = Bakkle.sharedInstance.garageItems[0]
            let imgURLs = topItem.valueForKey("image_urls") as! NSArray
            
            let firstURL = imgURLs[0] as! String
            let imgURL = NSURL(string: firstURL)
            if let imgData = NSData(contentsOfURL: imgURL!) {
                cell.imgView.contentMode = UIViewContentMode.ScaleAspectFill
                cell.setThumbnailImage(UIImage(data: imgData)!)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let chatsViewController = ChatsViewController()
        chatsViewController.chatItemID = (Bakkle.sharedInstance.garageItems[indexPath.row].valueForKey("pk") as! NSNumber).stringValue
        chatsViewController.garageIndex = indexPath.row
        self.navigationController?.pushViewController(chatsViewController, animated: true)
    }

    /* Camera */
    let albumName = "Bakkle"
    
    func showAddItem(){
        var addItem: UIViewController = AddItem()
        presentViewController(addItem, animated: true, completion: nil)
    }
    
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
                        destinationVC.scaledImages?.insert(resizedImage, atIndex: 0)
                    })
            }
        }
    }
    
}
