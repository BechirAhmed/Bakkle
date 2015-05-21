//
//  InterfaceController.swift
//  Bakkle WatchKit Extension
//
//  Created by Watterson, Lindsey M on 5/20/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var lblItemTitle: WKInterfaceLabel!
    @IBOutlet weak var lblItemPrice: WKInterfaceLabel!
    
    var item_id: String = ""
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        var dictonary = NSDictionary(objects: ["fetch"], forKeys: ["type"])
        
        WKInterfaceController.openParentApplication(dictonary as! [NSObject : AnyObject], reply: { (replyInfo, error) -> Void in
            
            var dictionary = replyInfo as NSDictionary
            
            let successString = dictionary["success"] as! String
            if successString == "yes"{
                let item_title = dictionary["item_title"] as! String
                let item_price = dictionary["item_price"] as! String
                self.item_id = dictionary["item_id"] as! String
                
                
                self.lblItemTitle.setText(item_title)
                self.lblItemPrice.setText("$" + item_price)
                //let image = dictionary["image"] as! UIImage
            } else {
                
            }
            
            println(successString)
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func openAction()
    {
        var dictonary = NSDictionary(objects: ["meh",item_id], forKeys: ["type", "item_id"])
        
        WKInterfaceController.openParentApplication(dictonary as! [NSObject : AnyObject], reply: { (replyInfo, error) -> Void in
            
            var dictionary = replyInfo as NSDictionary
            
            let successString = dictionary["success"] as! String
            let item_title = dictionary["item_title"] as! String
            let item_price = dictionary["item_price"] as! String
            self.item_id = dictionary["item_id"] as! String
            
            
            self.lblItemTitle.setText(item_title)
            self.lblItemPrice.setText("$" + item_price)
            //let image = dictionary["image"] as! UIImage
            
            println(successString)
        })
    }
}
