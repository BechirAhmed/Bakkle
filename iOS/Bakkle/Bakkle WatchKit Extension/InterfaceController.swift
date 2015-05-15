//
//  InterfaceController.swift
//  Bakkle WatchKit Extension
//
//  Created by local-tandoni on 5/14/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var imgView: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        
//        let topItem = Bakkle.sharedInstance.feedItems[0]
//
//        let imgURLs = topItem.valueForKey("image_urls") as! NSArray
//        let topTitle: String = topItem.valueForKey("title") as! String
//        let topPrice: String = topItem.valueForKey("price") as! String
//        
//        //println("[FeedScreen] Downloading image (top) \(imgURLs)")
//       
//        let firstURL = imgURLs[0] as! String
//        let imgURL = NSURL(string: firstURL)
//        var data = NSData(contentsOfURL: imgURL!)
//        imgView.setImageData(data)
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
