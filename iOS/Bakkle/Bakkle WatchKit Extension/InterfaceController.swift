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
            
            println(successString)
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func openAction()
    {
        var dictonary = NSDictionary(objects: ["fetch"], forKeys: ["type"])
        
        WKInterfaceController.openParentApplication(dictonary as! [NSObject : AnyObject], reply: { (replyInfo, error) -> Void in
            
            var dictionary = replyInfo as NSDictionary
            
            let successString = dictionary["success"] as! String
            let image = dictionary["image"] as! UIImage
            
            println(successString)
        })
    }
}
