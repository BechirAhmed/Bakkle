//
//  ItemDetails.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/20/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import MediaPlayer

class ItemDetails: UIViewController, UIScrollViewDelegate {

    var item: NSDictionary!
    let itemDetailsCellIdentifier = "ItemDetailsCell"
    var wanted: Bool = false
    var holding: Bool = false
    var available: Bool = true
    var videoURL: NSURL?
    var defaultPage: NSIndexPath?
    var itemImages: [NSURL]? = [NSURL]()
    var videoImages: [NSURL : UIImage] = [NSURL : UIImage]()
    
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var sellerAvatar: UIImageView!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemTagsTextView: UITextView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDistanceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    
    
    @IBOutlet weak var wantBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var detailBugHack: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingView.hidden = true
        if(Bakkle.sharedInstance.flavor == Bakkle.GOODWILL){
            self.detailBugHack.backgroundColor = Bakkle.sharedInstance.theme_base
            self.wantBtn.backgroundColor = Bakkle.sharedInstance.theme_base
        }

        activityInd?.startAnimating()
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "goback:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        setupButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        //TODO: This needs to load the item SENT to the view controller, not the top feed item.
        super.viewWillAppear(true)
        
        let model = UIDevice.currentDevice().model
        if model == "iPad" {
            imageContainer.addConstraint(NSLayoutConstraint(item: imageContainer, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageContainer, attribute: NSLayoutAttribute.Height, multiplier: 3/2, constant: 0.0))
            self.collectionView.pagingEnabled = false
        }else{
            imageContainer.addConstraint(NSLayoutConstraint(item: imageContainer, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageContainer, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0))
        }
        
        
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
        
        pageControl.currentPage = self.defaultPage != nil ? self.defaultPage!.row : 0
        
        //DONE (for videos): Load all images into an array and UIScrollView.
        if let images = itemImages {
            for url: NSURL in images {
                if url.pathExtension! == "mp4" {
                    self.videoImages[url] = Bakkle.sharedInstance.previewImageForLocalVideo(url)
                }
            }
        }
        
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
        itemPriceLabel.text = (topPrice as NSString).floatValue != 0 ? topPrice : "Offer"
        if description == "" {
            itemTagsTextView.text = tags
        }else {
            itemTagsTextView.text = descriptions
        }
        sellerName.text = sellersName
        itemDistanceLabel.text = String(format: "%d miles", roundDist(distance))
        
        for index in 0...imgURLs.count-1{
            let firstURL = imgURLs[index] as! String
            NSLog(firstURL)
            let imgURL = NSURL(string: firstURL)
            if imgURL != nil {
                self.itemImages?.insert(imgURL!, atIndex: index)
            }
        }
        
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
        
        if !available {
            wantBtn.enabled = available
            wantBtn.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    @IBAction func wantBtn(sender: AnyObject) {
        loadingView.hidden = false
        self.view.bringSubviewToFront(loadingView)
        if wanted {
            Bakkle.sharedInstance.markItem("sold", item_id: self.item!.valueForKey("pk")!.integerValue, success: {
                Bakkle.sharedInstance.populateTrunk({})
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
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
    
    func roundDist(distance: Double) -> Int {
        return Int((distance - floor(distance)) < 0.5 ? floor(distance) : ceil(distance))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let screenHeight = CGRectGetHeight(collectionView.bounds)
        return CGSize(width: screenHeight, height: screenHeight)
    }
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            let model = UIDevice.currentDevice().model
            if model == "iPad" {
                return 2
            }else{
                return 0
            }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :ItemDetailsCell = collectionView.dequeueReusableCellWithReuseIdentifier(itemDetailsCellIdentifier, forIndexPath: indexPath) as! ItemDetailsCell
        cell.imgView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.imgView.clipsToBounds  = true
        let imageURL = self.itemImages![indexPath.row]
        let fileExtension = imageURL.path?.pathExtension
        if fileExtension == "mp4" {
            if self.videoImages[imageURL] == nil {
                self.videoImages[imageURL] = Bakkle.sharedInstance.previewImageForLocalVideo(imageURL)
            }
            
            cell.imgView!.image = self.videoImages[imageURL]
            var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("videoTapped:"))
            self.videoURL = imageURL
            cell.imgView!.addGestureRecognizer(tapGestureRecognizer)
        } else {
            cell.imgView!.hnk_setImageFromURL(imageURL)
        }
        
        defaultPage = indexPath
        
        return cell
    }
    
    func videoTapped(sender: UITapGestureRecognizer) {
        for url in self.videoImages {
            if (sender.view as! UIImageView).image == url.1 {
                VideoPlayer.play(url.0, presentingController: self)
                break
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth: CGFloat  = collectionView.bounds.size.width
        var page: Int = Int(floor((collectionView.contentOffset.x - pageWidth / 2) / pageWidth)) + 1
        pageControl.currentPage = page
    }

}
