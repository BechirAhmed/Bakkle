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
    var timeRemaining: NSTimeInterval = 259200 {
        didSet {
            // TODO: This should calculate currentTime-timeWhenPlacedInHoldingPattern
            let (h,m,s) = secondsToHoursMinutesSeconds(Int(timeRemaining))
            var remaining = ""
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
                remaining = "2 days"
            }
            if timeRemaining > 172800 {
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
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    let statusCellIdentifier = "StatusCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    var activeItem: [Int]!
    var expiredItem: [Int]!
    var soldItem: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Bakkle.sharedInstance.flavor == Bakkle.GOODWILL){
            self.view.backgroundColor = Bakkle.sharedInstance.theme_base
        }
    
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        setupButtons()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkHoldingUpdate, object: nil, queue: mainQueue) { _ in
            self.classifyData()
            self.tableView.reloadData()
        }
        
        // Start time remaining timer
        self.timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("updateTimeRemaining"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)

        
        classifyData()
        Bakkle.sharedInstance.populateHolding({})
        
        self.titleBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goToFeed"))
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
    
    func goToFeed() {
        self.performSegueWithIdentifier("PushToFeedView", sender: self)
    }
    
    // helper function
    func getItem(indexPath: NSIndexPath) -> NSDictionary {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            let item = Bakkle.sharedInstance.holdingItems[activeItem[indexPath.row-1]] as! NSDictionary
            return item
        }else if indexPath.row > activeItem.count+1 && indexPath.row <= activeItem.count+soldItem.count+1 {
            let item = Bakkle.sharedInstance.holdingItems[soldItem[indexPath.row-2-activeItem.count]] as! NSDictionary
            return item
        }else {
            let item = Bakkle.sharedInstance.holdingItems[expiredItem[indexPath.row-3-activeItem.count-soldItem.count]] as! NSDictionary
            return item
        }
    }
    
    func removeAtIndex(indexPath: NSIndexPath) {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            Bakkle.sharedInstance.holdingItems.removeAtIndex(activeItem[indexPath.row-1])
        }else if indexPath.row > activeItem.count+1 && indexPath.row <= activeItem.count+soldItem.count+1 {
            Bakkle.sharedInstance.holdingItems.removeAtIndex(soldItem[indexPath.row-2-activeItem.count])
        }else {
            Bakkle.sharedInstance.holdingItems.removeAtIndex(expiredItem[indexPath.row-3-activeItem.count-soldItem.count])
        }
    }
    
    func getIndex(indexPath: NSIndexPath) -> Int {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            return activeItem[indexPath.row-1]
        }else if indexPath.row > activeItem.count+1 && indexPath.row <= activeItem.count+soldItem.count+1 {
            return soldItem[indexPath.row-2-activeItem.count]
        }else {
            return expiredItem[indexPath.row-3-activeItem.count-soldItem.count]
        }
        
    }
    
    func classifyData() {
        self.activeItem = [Int]()
        self.expiredItem = [Int]()
        self.soldItem = [Int]()
        if Bakkle.sharedInstance.holdingItems == nil || Bakkle.sharedInstance.holdingItems.count == 0 {
            return
        }
        for index in 0...Bakkle.sharedInstance.holdingItems.count-1 {
            let item = Bakkle.sharedInstance.holdingItems[index].valueForKey("item") as? NSDictionary
            let status = item?.valueForKey("status") as! String
            switch status {
            case "Active":
                let viewTime = Bakkle.sharedInstance.holdingItems[index].valueForKey("view_time") as! String
                var viewDate :NSDate = dateFormatter.dateFromString(viewTime)!
                var currentTime = NSDate()
                if viewDate.timeIntervalSinceDate(currentTime) + 259200 <= 0 {
                    self.expiredItem.append(index)
                }else{
                    self.activeItem.append(index)
                }
                break
            case "Sold":
                self.soldItem.append(index)
                break
            default: break
            }
        }
        
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == activeItem.count+1 || indexPath.row == activeItem.count + soldItem.count + 2 {
            return 30.0
        }
        return 100.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeItem == nil || expiredItem == nil || soldItem == nil {
            return 0
        }
        if activeItem.count != 0 || expiredItem.count != 0 || soldItem.count != 0 {
            println("Actually got items from the holding pattern!")
            println(String(Bakkle.sharedInstance.holdingItems.count) + " items in holding pattern")
            return activeItem.count + soldItem.count + expiredItem.count + 3
        }
        println("Didn't get anything in holding pattern")
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.numberOfRowsInSection(0) == 3 {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! UITableViewCell
            if indexPath.row == 1 {
                cell.textLabel!.text = "There are no items!"
            }
            cell.textLabel?.font = UIFont(name: "Avenir-Black", size: 25.0)
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return cell
        }
        if indexPath.row == 0 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Active (\(activeItem.count))"
            cell.statusLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }else if indexPath.row == activeItem.count + 1 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Sold (\(soldItem.count))"
            cell.statusLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        if indexPath.row == activeItem.count + soldItem.count + 2 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Expired (\(expiredItem.count))"
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
        let entry : NSDictionary = getItem(indexPath)
        let item = entry.valueForKey("item") as! NSDictionary
        let imgURLs : [String] = item.valueForKey("image_urls") as! [String]
        let firstURL = imgURLs[0] as String
        let imgURL = NSURL(string: firstURL)
        let viewTime = entry.valueForKey("view_time") as! String
        var viewDate :NSDate = dateFormatter.dateFromString(viewTime)!
        var currentTime = NSDate()
        cell.timeRemaining = viewDate.timeIntervalSinceDate(currentTime) + 259200
        
        
        cell.itemImage!.hnk_setImageFromURL(imgURL!)
        cell.titleLabel!.text = item.valueForKey("title") as? String
        cell.priceLabel!.text  = "$" + (item.valueForKey("price") as? String)!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 || indexPath.row == activeItem.count+1 || indexPath.row == activeItem.count + soldItem.count + 2  {
            return
        }
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ItemDetails = sb.instantiateViewControllerWithIdentifier("ItemDetails") as! ItemDetails
        vc.item = getItem(indexPath).valueForKey("item") as! NSDictionary
        vc.holding = true
        if indexPath.row > activeItem.count+1 {
            vc.available = false
        }
        self.presentViewController(vc, animated: true, completion: {})
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == activeItem.count+1 || indexPath.row == activeItem.count + soldItem.count + 2  {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = getItem(indexPath).valueForKey("item") as! NSDictionary
            Bakkle.sharedInstance.markItem("meh", item_id: item.valueForKey("pk")!.integerValue, success: {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.removeAtIndex(indexPath)
                    self.classifyData()
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
