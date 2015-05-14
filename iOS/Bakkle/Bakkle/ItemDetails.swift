//
//  ItemDetails.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/20/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ItemDetails: UIViewController {

    var item: NSDictionary?
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemTagsLabel: UILabel!
    
    @IBOutlet weak var itemMethodLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        activityInd.startAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        item = Bakkle.sharedInstance.feedItems[0] as? NSDictionary
        let imgURLs = item!.valueForKey("image_urls") as! NSArray
        
        //TOOD: Load all images into an array and UIScrollView.
        let firstURL = imgURLs[0] as! String
        let topTitle: String = item!.valueForKey("title") as! String
        let topPrice: String = item!.valueForKey("price") as! String
        let topMethod: String = item!.valueForKey("method") as! String
        let tags : [String] = item!.valueForKey("tags") as! [String]
        let tagString = ", ".join(tags)
        
        itemTitleLabel.text = topTitle.uppercaseString
        itemPriceLabel.text = "$" + topPrice
        itemMethodLabel.text = topMethod
        itemTagsLabel.text = tagString
        
        let imgURL = NSURL(string: firstURL)
        if imgURL == nil {
            return
        }
        if let imgData = NSData(contentsOfURL: imgURL!) {
            dispatch_async(dispatch_get_main_queue()) {
                println("[FeedScreen] displaying image (top)")
                self.imgDet.image = UIImage(data: imgData)
                self.imgDet.clipsToBounds = true
                self.imgDet.contentMode = UIViewContentMode.ScaleAspectFill
            }
        }

    }
    
    @IBAction func wantBtn(sender: AnyObject) {
        Bakkle.sharedInstance.markItem("want", item_id: self.item!.valueForKey("pk")!.integerValue, success: {}, fail: {})
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
