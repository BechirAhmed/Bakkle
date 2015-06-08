//
//  ItemDetails.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/20/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ItemDetails: UIViewController, UIScrollViewDelegate {

    var item: NSDictionary!
    let itemDetailsCellIdentifier = "ItemDetailsCell"
    var wanted: Bool = false
    var itemImages: [NSData]? = [NSData]()

    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemTagsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var itemMethodLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var wantLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        activityInd?.startAnimating()
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                break;
            case UISwipeGestureRecognizerDirection.Down:
                self.goback(self)
                break;
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //TODO: This needs to load the item SENT to the view controller, not the top feed item.
        super.viewWillAppear(true)
        if let index = Bakkle.sharedInstance.trunkItems {
            if (Bakkle.sharedInstance.trunkItems.count != 0) {
                for index in 0...Bakkle.sharedInstance.trunkItems.count-1 {
                    if item == Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as! NSDictionary {
                        wanted = true
                        wantLabel.text = "Accept Offer"
                        break
                    }
                }
            }
        }
        let imgURLs = item.valueForKey("image_urls") as! NSArray
        if imgURLs.count != 1 {
            pageControl.numberOfPages = imgURLs.count
        }else{
            pageControl.numberOfPages = 0
        }
        
        pageControl.currentPage = 0
        
        //TOOD: Load all images into an array and UIScrollView.
        
        let topTitle: String = item!.valueForKey("title") as! String
        let topPrice: String = item!.valueForKey("price") as! String
        let topMethod: String = item!.valueForKey("method") as! String
        let tags : [String] = item!.valueForKey("tags") as! [String]
        let tagString = ", ".join(tags)
        
        itemTitleLabel.text = topTitle.uppercaseString
        itemPriceLabel.text = "$" + topPrice
        itemMethodLabel.text = topMethod
        itemTagsLabel.text = tagString
        
        
        for index in 0...imgURLs.count-1{
            let firstURL = imgURLs[index] as! String
            let imgURL = NSURL(string: firstURL)
            if imgURL == nil {
                return
            }
            if let imgData = NSData(contentsOfURL: imgURL!) {
                dispatch_async(dispatch_get_main_queue()) {
                    println("[FeedScreen] displaying image (top)")
                    self.itemImages?.insert(imgData, atIndex: index)
                    var index: NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.collectionView.insertItemsAtIndexPaths([index])
                }
            }

        }
        
    }
    
    @IBAction func wantBtn(sender: AnyObject) {
        if wanted {
             Bakkle.sharedInstance.markItem("sold", item_id: self.item!.valueForKey("pk")!.integerValue, success: {}, fail: {})
        }
        else {
            Bakkle.sharedInstance.markItem("want", item_id: self.item!.valueForKey("pk")!.integerValue, success: {}, fail: {})
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        //TODO: refresh feed screen to get rid of the top card.
    }
    @IBAction func goback(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBOutlet weak var imgDet: UIImageView!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :ItemDetailsCell = collectionView.dequeueReusableCellWithReuseIdentifier(itemDetailsCellIdentifier, forIndexPath: indexPath) as! ItemDetailsCell
        cell.backgroundColor = UIColor.redColor()
        cell.imgView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.imgView.clipsToBounds  = true
        if let images = self.itemImages {
            cell.imgView.image = UIImage(data: itemImages![indexPath.row])
        }
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth: CGFloat  = collectionView.bounds.size.width
        var page: Int = Int(floor((collectionView.contentOffset.x - pageWidth / 2) / pageWidth)) + 1
        pageControl.currentPage = page
    }

}
