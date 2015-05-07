//
//  BuyersTrunkView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class BuyersTrunkCell : UITableViewCell {
    @IBOutlet var itemImage: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var priceLabel: UILabel?
    @IBOutlet var deliveryLabel: UILabel?
    @IBOutlet var tagLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    
    func loadCell(imgURLs: [String], title: String, price: String, delivery: String, tags: [String], indexPath: NSIndexPath) {
        println("[BuyersTrunk] Attempting to load image in cell")
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                let firstURL = imgURLs[0] as String
                let imgURL = NSURL(string: firstURL)
                if let imgData = NSData(contentsOfURL: imgURL!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        let superview: UITableView = self.superview?.superview! as! UITableView
                        if let cellToUpdate = superview.cellForRowAtIndexPath(indexPath) {
                            println("[BuyersTrunk] displaying cell image")
                            self.itemImage!.image = UIImage(data: imgData)
                            self.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
                            self.itemImage?.layer.cornerRadius = 4.0
                            self.itemImage?.clipsToBounds = true
                        }
                    }
                }
        }
        titleLabel!.text = title.capitalizedString
        priceLabel!.text = "$" + price
        deliveryLabel!.text = "Method of Delivery: " + delivery
        let tagString = ", ".join(tags)
        tagLabel!.text = "Tags: " + tagString
        distanceLabel!.text = "3 miles away"
    }
}

class BuyersTrunkView: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "BuyersTrunkCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "GarageRowCell")
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let x = Bakkle.sharedInstance.trunkItems {
            println("Actually got items from the trunk!")
            println(String(Bakkle.sharedInstance.trunkItems.count) + " items in trunk")
            return Bakkle.sharedInstance.trunkItems.count
        }
        println("Didn't get anything in trunk")
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("[BuyersTrunk] Updating table view")
        let cell = self.tableView.dequeueReusableCellWithIdentifier("BuyersTrunkCell") as! BuyersTrunkCell
        cell.itemImage?.image = UIImage(named: "blank.png")
        cell.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.itemImage?.layer.cornerRadius = 4.0
        cell.itemImage?.clipsToBounds = true
        if Bakkle.sharedInstance.trunkItems.count > 0 {
            let item : NSDictionary = Bakkle.sharedInstance.trunkItems[indexPath.row] as! NSDictionary
//            if let x: AnyObject = topItem.valueForKey("pk") {
//                self.item_id = Int(x.intValue)
//            }
            println(item.description)
            let imgURLs : [String] = item.valueForKey("image_urls") as! [String]
            let description : String = item.valueForKey("description") as! String
            let title : String = item.valueForKey("title") as! String
            let price : String = item.valueForKey("price") as! String
            let delivery : String = item.valueForKey("method") as! String
            let tags : [String] = item.valueForKey("tags") as! [String]
            cell.loadCell(imgURLs, title: title, price: price, delivery: delivery, tags: tags, indexPath: indexPath)
        } else {
            // No items in trunk
            println("[BuyersTrunk] Tried loading trunk items, none to be found")
        }
        return cell
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func btnAddItem(sender: AnyObject) {
        // Probably a seque instead
    }
    
}
