//
//  SellersGarage.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Photos
import Haneke

class SellersGarageView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let garageCellIdentifier = "GarageCell"
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        setupButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Register for garage updates
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkGarageUpdate, object: nil, queue: mainQueue) { _ in
            println("Received garage update")
            self.refreshData()
        }

        requestUpdates()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    /* New data arrived, update the garage on screen */
    func refreshData() {
        Bakkle.sharedInstance.info("Refreshing sellers garage items")
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    /* Request update from server */
    func requestUpdates() {
        println("[Sellers Garage] Requesting updates from server")
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            Bakkle.sharedInstance.populateGarage({})
        }
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.revealViewController().revealToggleAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Bakkle.sharedInstance.garageItems != nil ? Bakkle.sharedInstance.garageItems.count : 0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(100.0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : GarageCell = tableView.dequeueReusableCellWithIdentifier(self.garageCellIdentifier, forIndexPath: indexPath) as! GarageCell
        
        // Load image
        if Bakkle.sharedInstance.garageItems != nil {
            cell.setCornerRadius()
            
            let item = Bakkle.sharedInstance.garageItems[indexPath.row]
            let imgURLs = item.valueForKey("image_urls") as! NSArray
            
            let firstURL = imgURLs[0] as! String
            let imgURL = NSURL(string: firstURL)
            cell.imgView.hnk_setImageFromURL(imgURL!)
            cell.imgView.layer.cornerRadius = 10.0
            cell.imageView?.clipsToBounds = true
            cell.background.layer.cornerRadius = 10.0
            
            cell.nameLabel.text = item.valueForKey("title") as? String
            
            let topPrice: String = item.valueForKey("price") as! String
            var myString : String = ""
            if suffix(topPrice, 2) == "00" {
                let withoutZeroes = "$\((topPrice as NSString).integerValue)"
                myString = withoutZeroes
            } else {
                myString = "$" + topPrice
            }
            cell.priceLabel.text = myString
            
            cell.numHold.text = (item.valueForKey("number_of_holding") as! NSNumber).stringValue
            cell.holdView.layer.cornerRadius = 15.0
            
            cell.numLike.text = (item.valueForKey("number_of_want") as! NSNumber).stringValue
            cell.likeView.layer.cornerRadius = 15.0
            
            cell.numNope.text = (item.valueForKey("number_of_meh") as! NSNumber).stringValue
            cell.nopeView.layer.cornerRadius = 15.0
            
            cell.numViews.text = (item.valueForKey("number_of_views") as! NSNumber).stringValue
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chatsViewController = ChatsViewController()
        chatsViewController.chatItemID = (Bakkle.sharedInstance.garageItems[indexPath.row].valueForKey("pk") as! NSNumber).stringValue
        chatsViewController.garageIndex = indexPath.row
        self.navigationController?.pushViewController(chatsViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = Bakkle.sharedInstance.garageItems[indexPath.row] as! NSDictionary
            Bakkle.sharedInstance.removeItem(item.valueForKey("pk")!.integerValue, success: {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    Bakkle.sharedInstance.garageItems.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                })
            }, fail: {})
            
        }
    }
}
