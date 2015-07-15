//
//  HoldingPatternView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Haneke

class HoldingPatternCell : UITableViewCell {
    @IBOutlet var itemImage: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var priceLabel: UILabel?
    @IBOutlet var timeRemainingLabel: UILabel?

    
//    259200 = 4 days
    var timeRemaining: NSTimeInterval = 5400 {
        didSet {
            // TODO: This should calculate currentTime-timeWhenPlacedInHoldingPattern
            let (h,m,s) = secondsToHoursMinutesSeconds(Int(timeRemaining))
            var remaining = "--"
            if timeRemaining > 0 {
                remaining = String(format: "%02d", s)
            }
            if timeRemaining > 60 {
                remaining = String(format: "%02d:", m) + remaining
            }
            if timeRemaining > 3600 {
                remaining = String(format: "%d:", h) + remaining
            }
            if timeRemaining > 86400 {
                remaining = "1 day"
            }
            if timeRemaining > 172800 {
                remaining = "2 days"
            }
            if timeRemaining > 259200 {
                remaining = "3 days"
            }
            self.timeRemainingLabel?.text = remaining
        }
    }
    
    func updateTimeRemaining() {
        if self.timeRemaining > 0 {
            --self.timeRemaining
        }
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("updateTimeRemaining"), name: HoldingPatternView.bkTimeRemainingUpdate, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

class HoldingPatternView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let bkTimeRemainingUpdate    = "com.bakkle.timeRemainingUpdate"

    var timer: NSTimer!
    
    let statusCellIdentifier = "StatusCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        setupButtons()
        
        self.tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkHoldingUpdate, object: nil, queue: mainQueue) { _ in
            self.tableView.reloadData()
        }
        
        // Start time remaining timer
        self.timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("updateTimeRemaining"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)

        Bakkle.sharedInstance.populateHolding({});
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.timer?.invalidate()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.timer?.invalidate()
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == Bakkle.sharedInstance.holdingItems.count + 1 || indexPath.row == Bakkle.sharedInstance.holdingItems.count + 2 {
            return CGFloat (30.0)
        }
        return CGFloat(100.0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let x = Bakkle.sharedInstance.holdingItems {
            println("Actually got items from the holding pattern!")
            println(String(Bakkle.sharedInstance.holdingItems.count) + " items in holding pattern")
            return Bakkle.sharedInstance.holdingItems.count + 3
        }
        println("Didn't get anything in holding pattern")
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Active (\(Bakkle.sharedInstance.holdingItems.count))"
            cell.statusLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }else if indexPath.row == Bakkle.sharedInstance.holdingItems.count + 1 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Sold (\(0))"
            cell.statusLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        if indexPath.row == Bakkle.sharedInstance.holdingItems.count + 2 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Expired (\(0))"
            cell.statusLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        
        println("[HoldingPattern] Updating table view")
        let cell = self.tableView.dequeueReusableCellWithIdentifier("HoldingPatternCell") as! HoldingPatternCell
        cell.itemImage?.image = UIImage(named: "blank.png")
        cell.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.itemImage?.layer.cornerRadius = 10.0
        cell.itemImage?.clipsToBounds = true
        let entry : NSDictionary = Bakkle.sharedInstance.holdingItems[indexPath.row-1] as! NSDictionary
        let item = entry.valueForKey("item") as! NSDictionary
        let imgURLs : [String] = item.valueForKey("image_urls") as! [String]
        let firstURL = imgURLs[0] as String
        let imgURL = NSURL(string: firstURL)
        cell.itemImage!.hnk_setImageFromURL(imgURL!)
            
        cell.titleLabel!.text = item.valueForKey("title") as? String
        cell.priceLabel!.text  = "$" + (item.valueForKey("price") as? String)!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 || indexPath.row == Bakkle.sharedInstance.holdingItems.count + 1 || indexPath.row == Bakkle.sharedInstance.holdingItems.count + 2 {
            return
        }
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ItemDetails = sb.instantiateViewControllerWithIdentifier("ItemDetails") as! ItemDetails
        vc.item = Bakkle.sharedInstance.holdingItems[indexPath.row-1].valueForKey("item") as! NSDictionary
        self.presentViewController(vc, animated: true, completion: {})
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == Bakkle.sharedInstance.holdingItems.count + 1 || indexPath.row == Bakkle.sharedInstance.holdingItems.count + 2 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = Bakkle.sharedInstance.holdingItems[indexPath.row-1].valueForKey("item") as! NSDictionary
            Bakkle.sharedInstance.markItem("meh", item_id: item.valueForKey("pk")!.integerValue, success: {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    Bakkle.sharedInstance.holdingItems.removeAtIndex(indexPath.row-1)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    tableView.reloadData()
                })
            }, fail: {})
            
        }
    }
    
    func updateTimeRemaining() {
        let notification = NSNotification(name: HoldingPatternView.bkTimeRemainingUpdate, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
}
