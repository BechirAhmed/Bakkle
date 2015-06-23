//
//  BuyersTrunkView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Haneke

class BuyersTrunkCell : UITableViewCell {
    @IBOutlet var itemImage: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var priceLabel: UILabel?
    @IBOutlet var deliveryLabel: UILabel?
    @IBOutlet var tagLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    
    func loadCell(imgURLs: [String], title: String, price: String, delivery: String, tags: [String], location: String, indexPath: NSIndexPath) {
        println("[BuyersTrunk] Attempting to load image in cell")
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                let firstURL = imgURLs[0] as String
                let imgURL = NSURL(string: firstURL)
                dispatch_async(dispatch_get_main_queue()) {
                    let superview: UITableView = self.superview?.superview! as! UITableView
                    if let cellToUpdate = superview.cellForRowAtIndexPath(indexPath) {
                        println("[BuyersTrunk] displaying cell image")
                        self.itemImage!.hnk_setImageFromURL(imgURL!)
                        self.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
                        self.itemImage?.layer.cornerRadius = 4.0
                        self.itemImage?.clipsToBounds = true
                    }
                }
        }
        titleLabel!.text = title.uppercaseString
        priceLabel!.text = "$" + price
        deliveryLabel!.text = "Method of Delivery: " + delivery
        let tagString = ", ".join(tags)
        tagLabel!.text = "Tags: " + tagString
        distanceLabel!.text = ""
        if location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let start: CLLocation = CLLocation(locationString: location)
            if let distance = Bakkle.sharedInstance.distanceTo(start) {
                
                var distanceString = distance.rangeString()
                distanceLabel!.text = "\(distanceString) miles away"
//                if distance >= 10 {
//                    var formatter:NSNumberFormatter = NSNumberFormatter()
//                    formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
//                    var formattedOutput = formatter.stringFromNumber(Int(distance))
//                    distanceLabel!.text = "\(formattedOutput!) miles away"
//                } else {
//                    distanceLabel!.text = String(format: "%.1f", distance) + " miles away"
//                }
            }
        }
    }
}

class BuyersTrunkView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "BuyersTrunkCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "GarageCell")
        setupButtons()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkTrunkUpdate, object: nil, queue: mainQueue) { _ in
            self.tableView.reloadData()
        }
        
        Bakkle.sharedInstance.populateTrunk({});
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let x = Bakkle.sharedInstance.trunkItems {
            println("Actually got items from the trunk!")
            println(String(Bakkle.sharedInstance.trunkItems.count) + " items in trunk")
            return Bakkle.sharedInstance.trunkItems.count
        }
        println("Didn't get anything in trunk")
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("[BuyersTrunk] Updating table view")
        let cell = self.tableView.dequeueReusableCellWithIdentifier("BuyersTrunkCell") as! BuyersTrunkCell
        cell.itemImage?.image = UIImage(named: "blank.png")
        cell.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.itemImage?.layer.cornerRadius = 4.0
        cell.itemImage?.clipsToBounds = true
        if Bakkle.sharedInstance.trunkItems.count > 0 {
            let trunkEntry : NSDictionary = Bakkle.sharedInstance.trunkItems[indexPath.row] as! NSDictionary
            let item = trunkEntry.valueForKey("item") as! NSDictionary
            println(item.description)
            let imgURLs : [String] = item.valueForKey("image_urls") as! [String]
            let description : String = item.valueForKey("description") as! String
            let title : String = item.valueForKey("title") as! String
            let price : String = item.valueForKey("price") as! String
            let delivery : String = item.valueForKey("method") as! String
            let tags : [String] = item.valueForKey("tags") as! [String]
            let location : String =
                item.valueForKey("location") as! String
            cell.loadCell(imgURLs, title: title, price: price, delivery: delivery, tags: tags, location: location, indexPath: indexPath)
        } else {
            // No items in trunk
            println("[BuyersTrunk] Tried loading trunk items, none to be found")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let buyer = User(facebookID: Bakkle.sharedInstance.facebook_id_str,
            firstName: Bakkle.sharedInstance.first_name, lastName: Bakkle.sharedInstance.last_name)
        let account = Account(user: buyer)
        let chatItem = Bakkle.sharedInstance.trunkItems[indexPath.row].valueForKey("item") as! NSDictionary
        let chatItemId = (chatItem.valueForKey("pk") as! NSNumber).stringValue
        var chatId: Int = 0
        var chatPayload: WSRequest = WSStartChatRequest(itemId: chatItemId)
        chatPayload.successHandler = {
            (var success: NSDictionary) in
            chatId = success.valueForKey("chatId") as! Int
            var buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chatId)
            let chatViewController = ChatViewController(chat: buyerChat)
            chatViewController.index = indexPath.row
            chatViewController.seller = chatItem.valueForKey("seller") as! NSDictionary
            chatViewController.isBuyer = true
            self.presentViewController(chatViewController, animated: true, completion: {})
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        WSManager.enqueueWorkPayload(chatPayload)  
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = Bakkle.sharedInstance.trunkItems[indexPath.row].valueForKey("item") as! NSDictionary
            Bakkle.sharedInstance.markItem("meh", item_id: item.valueForKey("pk")!.integerValue, success: {}, fail: {})
            Bakkle.sharedInstance.trunkItems.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
}
