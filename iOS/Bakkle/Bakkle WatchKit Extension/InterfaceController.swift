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
    @IBOutlet weak var lblNoItems: WKInterfaceLabel!
    @IBOutlet weak var lblRunApp: WKInterfaceLabel!
    @IBOutlet weak var btnWant: WKInterfaceButton!
    @IBOutlet weak var btnMeh: WKInterfaceButton!
    
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
            
            if replyInfo != nil{
                var dictionary = replyInfo as NSDictionary
                self.lblRunApp.setHidden(true)
                self.btnMeh.setHidden(false)
                self.btnWant.setHidden(false)
                let successString = dictionary["success"] as! String
                if successString == "yes"{
                    self.lblNoItems.setHidden(true)
                    self.lblItemPrice.setHidden(false)
                    self.lblItemTitle.setHidden(false)
                    let item_title = dictionary["item_title"] as! String
                    let item_price = dictionary["item_price"] as! String
                    self.item_id = dictionary["item_id"] as! String
                    
                    
                    self.lblItemTitle.setText(item_title)
                    self.lblItemPrice.setText("$" + item_price)
                    //let image = dictionary["image"] as! UIImage
                } else {
                    self.lblNoItems.setHidden(false)
                    self.lblItemPrice.setHidden(true)
                    self.lblItemTitle.setHidden(true)
                    self.item_id = ""
                }
                
                println(successString)
            }else {
                self.lblRunApp.setHidden(false)
                self.btnMeh.setHidden(true)
                self.btnWant.setHidden(true)
            }
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func mehAction()
    {
        var dictonary = NSDictionary(objects: ["meh",item_id], forKeys: ["type", "item_id"])
        
        WKInterfaceController.openParentApplication(dictonary as! [NSObject : AnyObject], reply: { (replyInfo, error) -> Void in
            
            if replyInfo != nil{
                var dictionary = replyInfo as NSDictionary
                self.lblRunApp.setHidden(true)
                self.btnMeh.setHidden(false)
                self.btnWant.setHidden(false)
                let successString = dictionary["success"] as! String
                if successString == "yes"{
                    self.lblNoItems.setHidden(true)
                    self.lblItemPrice.setHidden(false)
                    self.lblItemTitle.setHidden(false)
                    let item_title = dictionary["item_title"] as! String
                    let item_price = dictionary["item_price"] as! String
                    self.item_id = dictionary["item_id"] as! String
                    
                    
                    self.lblItemTitle.setText(item_title)
                    self.lblItemPrice.setText("$" + item_price)
                    //let image = dictionary["image"] as! UIImage
                    
                    
                } else {
                    self.lblNoItems.setHidden(false)
                    self.lblItemPrice.setHidden(true)
                    self.lblItemTitle.setHidden(true)
                    self.item_id = ""
                }
                println(successString)
            }else {
                self.lblRunApp.setHidden(false)
                self.btnMeh.setHidden(true)
                self.btnWant.setHidden(true)
            }
        })
    }
    
    @IBAction func wantAction()
    {
        var dictonary = NSDictionary(objects: ["want",item_id], forKeys: ["type", "item_id"])
        WKInterfaceController.openParentApplication(dictonary as! [NSObject : AnyObject], reply: { (replyInfo, error) -> Void in
            
            if replyInfo != nil{
                var dictionary = replyInfo as NSDictionary
                self.lblRunApp.setHidden(true)
                self.btnMeh.setHidden(false)
                self.btnWant.setHidden(false)
            
                let successString = dictionary["success"] as! String
                if successString == "yes"{
                    self.lblNoItems.setHidden(true)
                    self.lblItemPrice.setHidden(false)
                    self.lblItemTitle.setHidden(false)
                    let item_title = dictionary["item_title"] as! String
                    let item_price = dictionary["item_price"] as! String
                    self.item_id = dictionary["item_id"] as! String
                    
                    
                    self.lblItemTitle.setText(item_title)
                    self.lblItemPrice.setText("$" + item_price)
                    //let image = dictionary["image"] as! UIImage
                    
                    
                } else {
                    self.lblNoItems.setHidden(false)
                    self.lblItemPrice.setHidden(true)
                    self.lblItemTitle.setHidden(true)
                    self.item_id = ""
                }
                println(successString)
            }else {
                self.lblRunApp.setHidden(false)
                self.btnMeh.setHidden(true)
                self.btnWant.setHidden(true)
            }
        })
    }
}
