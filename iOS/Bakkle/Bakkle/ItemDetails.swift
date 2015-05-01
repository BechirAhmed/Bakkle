//
//  ItemDetails.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/20/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ItemDetails: UIViewController {

    @IBOutlet weak var itemTitleLabel: UILabel!
    
    @IBOutlet weak var itemMethodLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        activityInd.startAnimating()

    }
    
    override func viewWillAppear(animated: Bool) {
        var topItem = Bakkle.sharedInstance.feedItems[0]
        let imgURLs = topItem.valueForKey("image_urls") as! NSArray
        
        //TOOD: Load all images into an array and UIScrollView.
        let firstURL = imgURLs[0] as! String
        let topTitle: String = topItem.valueForKey("title") as! String
        let topPrice: String = topItem.valueForKey("price") as! String
        let topMethod: String = topItem.valueForKey("method") as! String
        
        itemTitleLabel.text = topTitle.uppercaseString
        itemPriceLabel.text = "$" + topPrice
        itemMethodLabel.text = topMethod
        
        let imgURL = NSURL(string: firstURL)
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
        let alertController = UIAlertController(title: "Bakkle", message:
            "Not implemented yet.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
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
