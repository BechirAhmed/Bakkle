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
    
    let photoCellIdentifier = "PhotoCell"
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var assetThumbnailSize: CGSize!
    
    var chosenImage: UIImage?
    let addItemSegue = "AddItemSegueFromGarage"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        return 10
        return Bakkle.sharedInstance.garageItems != nil ? Bakkle.sharedInstance.garageItems.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : CollectionThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! CollectionThumbnail
        
        cell.setThumbnailImage(UIImage(named: "blank.png")!)
        cell.contentMode = UIViewContentMode.ScaleAspectFill

        //        populateCells(cell)
//        collectionView.reloadData()
        
        // Load image
        if Bakkle.sharedInstance.garageItems != nil {
            let item = Bakkle.sharedInstance.garageItems[indexPath.row]
            let imgURLs = item.valueForKey("image_urls") as! NSArray
            
            let firstURL = imgURLs[0] as! String
            let imgURL = NSURL(string: firstURL)
            cell.imgView.hnk_setImageFromURL(imgURL!)
            cell.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
//        let asset: PHAsset = self.photosAsset[indexPath.item] as! PHAsset
//
//        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.assetThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: {(result, info) in
//            cell.setThumbnailImage(result)
//        })
        return cell
    }
    
    func populateCells(cell: CollectionThumbnail) {
        if Bakkle.sharedInstance.garageItems.count > 0 {
            let topItem = Bakkle.sharedInstance.garageItems[0]
            let imgURLs = topItem.valueForKey("image_urls") as! NSArray
            
            let firstURL = imgURLs[0] as! String
            let imgURL = NSURL(string: firstURL)
            if let imgData = NSData(contentsOfURL: imgURL!) {
                cell.setThumbnailImage(UIImage(data: imgData)!)
                cell.imgView.contentMode = UIViewContentMode.ScaleAspectFill
            }
        }
    }

    /* Camera */
    let albumName = "Bakkle"
    
    func showAddItem(){
        var addItem: UIViewController = AddItem()
        presentViewController(addItem, animated: true, completion: nil)
    }
    
    // Display camera as first step of add-item
    @IBAction func btnAddItem(sender: AnyObject) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: false, completion: nil)
            
        } else{
            //no camera available
            var alert = UIAlertController(title: "Sorry", message: "Bakkle requires a picture when selling items", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(false, completion: nil)
            }))
            self.presentViewController(alert, animated: false, completion: nil)
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
            destinationVC.itemImage = self.chosenImage
        }
    }
    
}
