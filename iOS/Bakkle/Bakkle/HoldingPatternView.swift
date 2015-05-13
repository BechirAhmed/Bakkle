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
    @IBOutlet var deliveryLabel: UILabel?
    @IBOutlet var tagLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var timeRemainingLabel: UILabel?
    
    func loadCell(imgURLs: [String], title: String, price: String, delivery: String, tags: [String], location: String, indexPath: NSIndexPath) {
        println("[HoldingPattern] Attempting to load image in cell")
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                let firstURL = imgURLs[0] as String
                let imgURL = NSURL(string: firstURL)
                dispatch_async(dispatch_get_main_queue()) {
                    let superview: UITableView = self.superview?.superview! as! UITableView
                    if let cellToUpdate = superview.cellForRowAtIndexPath(indexPath) {
                        println("[HoldingPattern] displaying cell image")
                        self.itemImage!.hnk_setImageFromURL(imgURL!)
                        self.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
                        self.itemImage?.layer.cornerRadius = 4.0
                        self.itemImage?.clipsToBounds = true
                    }
                }
        }
        titleLabel!.text = title.capitalizedString
        priceLabel!.text = "$" + price
        deliveryLabel!.text = "Method of Delivery: " + delivery
        let tagString = ", ".join(tags)
        tagLabel!.text = "Tags: " + tagString
        distanceLabel!.text = ""
        if location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let start: CLLocation = CLLocation(locationString: location)
            if let distance = Bakkle.sharedInstance.distanceTo(start) {
                if distance >= 10 {
                    var formatter:NSNumberFormatter = NSNumberFormatter()
                    formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                    var formattedOutput = formatter.stringFromNumber(Int(distance))
                    distanceLabel!.text = "\(formattedOutput!) miles away"
                } else {
                    distanceLabel!.text = String(format: "%.1f", distance) + " miles away"
                }
            }
        }
        timeRemainingLabel!.text = "55:55" //TODO: Set this to count down
    }
    
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
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "HoldingPatternCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "HoldingPatternRowCell")
        
        // Start time remaining timer
        self.timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("updateTimeRemaining"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkHoldingUpdate, object: nil, queue: mainQueue) { _ in
            self.tableView.reloadData()
        }
        
        Bakkle.sharedInstance.populateHolding({});
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let x = Bakkle.sharedInstance.holdingItems {
            println("Actually got items from the holding pattern!")
            println(String(Bakkle.sharedInstance.holdingItems.count) + " items in holding pattern")
            return Bakkle.sharedInstance.holdingItems.count
        }
        println("Didn't get anything in holding pattern")
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("[HoldingPattern] Updating table view")
        let cell = self.tableView.dequeueReusableCellWithIdentifier("HoldingPatternCell") as! HoldingPatternCell
        cell.itemImage?.image = UIImage(named: "blank.png")
        cell.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.itemImage?.layer.cornerRadius = 4.0
        cell.itemImage?.clipsToBounds = true
        if Bakkle.sharedInstance.holdingItems.count > 0 {
            let entry : NSDictionary = Bakkle.sharedInstance.holdingItems[indexPath.row] as! NSDictionary
            //            if let x: AnyObject = topItem.valueForKey("pk") {
            //                self.item_id = Int(x.intValue)
            //            }
            let item = entry.valueForKey("item") as! NSDictionary
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
            println("[HoldingPattern] Tried loading holding pattern items, none to be found")
        }
        return cell
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
