//
//  ItemDetails.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/20/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ItemDetails: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        activityInd.startAnimating()

    }
    
    override func viewWillAppear(animated: Bool) {
        var topItem = Bakkle.sharedInstance.feedItems[0]
        var itemDetails: NSDictionary = topItem.valueForKey("fields") as! NSDictionary
        let imgURLs: String = itemDetails.valueForKey("image_urls") as! String
        
        let imgURL = NSURL(string: imgURLs)
        if let imgData = NSData(contentsOfURL: imgURL!) {
            dispatch_async(dispatch_get_main_queue()) {
                println("[FeedScreen] displaying image (top)")
                self.imgDet.image = UIImage(data: imgData)
                self.imgDet.contentMode = UIViewContentMode.ScaleAspectFill
            }
        }

    }
    
    @IBAction func goback(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
