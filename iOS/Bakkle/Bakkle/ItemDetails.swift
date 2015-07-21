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
    var holding: Bool = false
    var itemImages: [NSData]? = [NSData]()
    
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var sellerAvatar: UIImageView!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemTagsTextView: UITextView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDistanceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var wantBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var detailBugHack: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Bakkle.sharedInstance.flavor == 2){
            self.detailBugHack.backgroundColor = Bakkle.sharedInstance.theme_base
            self.wantBtn.backgroundColor = Bakkle.sharedInstance.theme_base
        }

        activityInd?.startAnimating()
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "goback:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        setupButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let sellerProfile: NSDictionary = item!.valueForKey("seller") as! NSDictionary
        let sellerFBID: String = sellerProfile.valueForKey("facebook_id") as! String
        let sellerFacebookProfileImgString = "http://graph.facebook.com/\(sellerFBID)/picture?width=142&height=142"
        let profileImageURL = NSURL(string: sellerFacebookProfileImgString)
        println("FACEBOOK PROFILE LINK IS: \(sellerFacebookProfileImgString)")
        sellerAvatar.image = UIImage(data: NSData(contentsOfURL: profileImageURL!)!)
        sellerAvatar.layer.borderWidth = 2.0
        sellerAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        sellerAvatar.layer.cornerRadius = sellerAvatar.layer.frame.size.width / 2
        sellerAvatar.layer.masksToBounds = true
    }
    
    func setupButtons() {
        closeBtn.setImage(IconImage().close(), forState: .Normal)
        closeBtn.setTitle("", forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        //TODO: This needs to load the item SENT to the view controller, not the top feed item.
        super.viewWillAppear(true)
        if let index = Bakkle.sharedInstance.trunkItems {
            if (Bakkle.sharedInstance.trunkItems.count != 0) {
                for index in 0...Bakkle.sharedInstance.trunkItems.count-1 {
                    if item == Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as! NSDictionary {
                        wanted = true
                        wantBtn.setTitle("ACCEPT OFFER", forState: UIControlState.Normal)
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
        
        let sellerProfile: NSDictionary = item!.valueForKey("seller") as! NSDictionary
        // get the first name of the seller (split seller name by " " and get first element)
        let sellersName: String = (split(sellerProfile.valueForKey("display_name") as! String) {$0 == " "})[0]
        let sellerFBID: String = sellerProfile.valueForKey("facebook_id") as! String
        let sellerFacebookProfileImgString = "http://graph.facebook.com/\(sellerFBID)/picture?width=142&height=142"
        let topTitle: String = item!.valueForKey("title") as! String
        let topPrice: String = item!.valueForKey("price") as! String
        let tags = item!.valueForKey("tags") as! String
        let descriptions: String = item!.valueForKey("description") as! String
        let location: String = item!.valueForKey("location") as! String
        let distance = Bakkle.sharedInstance.distanceTo(CLLocation(locationString: location)) as CLLocationDistance!
        
        itemTitleLabel.text = topTitle
        itemPriceLabel.text = "$" + topPrice
        if description == "" {
            itemTagsTextView.text = tags
        }else {
            itemTagsTextView.text = descriptions
        }
        sellerName.text = sellersName
        itemDistanceLabel.text = String(format: "%.2f miles", distance)
        
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
            Bakkle.sharedInstance.markItem("sold", item_id: self.item!.valueForKey("pk")!.integerValue, success: {
                Bakkle.sharedInstance.populateTrunk({})
                self.dismissViewControllerAnimated(true, completion: nil)
                }, fail: {})
        }
        else {
            Bakkle.sharedInstance.markItem("want", item_id: self.item!.valueForKey("pk")!.integerValue, success: {
                if self.holding {
                    Bakkle.sharedInstance.populateHolding({
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }else {
                    Bakkle.sharedInstance.feedItems.removeAtIndex(0)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                }, fail: {})
        }
        //TODO: refresh feed screen to get rid of the top card.
    }
    @IBAction func goback(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

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
