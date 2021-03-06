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

class StatusCell: UITableViewCell {
    @IBOutlet weak var statusLabel: UILabel!
}

class SellersGarageView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let garageCellIdentifier = "GarageCell"
    let statusCellIdentifier = "StatusCell"
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    var activeItem: [Int]!
    var soldItem: [Int]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // display status bar every time the screen shows up
        UIApplication.sharedApplication().statusBarHidden = false

        
        setupButtons()
        
        self.tableView.tableFooterView = UIView()
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

        self.view.userInteractionEnabled = true
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        
        
        classifyData()
        requestUpdates()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // helper function
    func getItem(indexPath: NSIndexPath) -> NSDictionary {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            let item = Bakkle.sharedInstance.garageItems[activeItem[indexPath.row-1]] as! NSDictionary
            return item
        }else {
            let item = Bakkle.sharedInstance.garageItems[soldItem[indexPath.row-2-activeItem.count]] as! NSDictionary
            return item
        }
    }
    
    func removeAtIndex(indexPath: NSIndexPath) {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            Bakkle.sharedInstance.garageItems.removeAtIndex(activeItem[indexPath.row-1])
        }else {
            Bakkle.sharedInstance.garageItems.removeAtIndex(soldItem[indexPath.row-2-activeItem.count])
        }
    }
    
    func getIndex(indexPath: NSIndexPath) -> Int {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            return activeItem[indexPath.row-1]
        }else {
            return soldItem[indexPath.row-2-activeItem.count]
        }
        
    }
    
    func classifyData() {
        self.activeItem = [Int]()
        self.soldItem = [Int]()
        if Bakkle.sharedInstance.garageItems == nil || Bakkle.sharedInstance.garageItems.count == 0 {
            return
        }
        for index in 0...Bakkle.sharedInstance.garageItems.count-1 {
            let item = Bakkle.sharedInstance.garageItems[index] as? NSDictionary
            let status = item?.valueForKey("status") as! String
            switch status {
            case "Active":
                self.activeItem.append(index)
                break
            case "Sold":
                self.soldItem.append(index)
                break
            default: break
            }
        }
        
    }
    
    func updateStatusCell() {
        self.tableView.beginUpdates()
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.activeItem.count+1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.endUpdates()
    }

    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    /* New data arrived, update the garage on screen */
    func refreshData() {
        Bakkle.sharedInstance.info("Refreshing sellers garage items")
        dispatch_async(dispatch_get_main_queue()) {
            self.classifyData()
            self.tableView.reloadData()
        }
    }
    
    /* Request update from server */
    func requestUpdates() {
        println("[Sellers Garage] Requesting updates from server")
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            Bakkle.sharedInstance.populateGarage({ })
        }
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if Bakkle.sharedInstance.account_type == 0 {
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
            let vc = sb.instantiateViewControllerWithIdentifier("CameraView") as! CameraView
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeItem == nil || soldItem == nil {
            return 0
        }
        if activeItem.count != 0 || soldItem.count != 0 {
            println("Actually got items from the garage!")
            println(String(Bakkle.sharedInstance.garageItems.count) + " items in garage")
            return activeItem.count + soldItem.count  + 2
        }
        println("Didn't get anything in garage")
        return 2;
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == activeItem.count + 1 {
            return 30.0
        }
        return 100.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.numberOfRowsInSection(0) == 2 {
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
        
        let cell : GarageCell = tableView.dequeueReusableCellWithIdentifier(self.garageCellIdentifier, forIndexPath: indexPath) as! GarageCell
        
        let item = getItem(indexPath) as NSDictionary
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
        
        cell.selectorView.userInteractionEnabled = true
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        cell.selectorView.addGestureRecognizer(tapGestureRecognizer)
//        cell.selectorView.tag = indexPath.row
        cell.selectorView.tag = getIndex(indexPath)
        return cell
    }
    
    @IBAction func addItemTapped(sender: AnyObject) {
        if !Bakkle.sharedInstance.isInternetConnected() {
            self.noInternetConnectionAlert()
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if Bakkle.sharedInstance.checkPermission(Bakkle.bkPermissionAddItem) {
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
            let vc = sb.instantiateViewControllerWithIdentifier("CameraView") as! CameraView
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func imageTapped(sender: UITapGestureRecognizer){
        if !Bakkle.sharedInstance.isInternetConnected() {
            self.noInternetConnectionAlert()
            return
        }
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ItemDetails = sb.instantiateViewControllerWithIdentifier("ItemDetails") as! ItemDetails
        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        vc.item = Bakkle.sharedInstance.garageItems[sender.view!.tag] as! NSDictionary
        vc.available = false
        let status = vc.item.valueForKey("status") as! String
        if status == "Sold" {
            vc.available = false
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !Bakkle.sharedInstance.isInternetConnected() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.noInternetConnectionAlert()
            return
        }
        if indexPath.row == 0 || indexPath.row == activeItem.count + 1 {
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if Bakkle.sharedInstance.account_type == 0 {
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
            let chatsViewController = ChatsViewController()
            chatsViewController.chatItemID = (getItem(indexPath).valueForKey("pk") as! NSNumber).stringValue
            chatsViewController.garageIndex = getIndex(indexPath)
            self.navigationController?.pushViewController(chatsViewController, animated: true)
            self.view.userInteractionEnabled = false
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
       
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if !Bakkle.sharedInstance.isInternetConnected() {
            return false
        }
        if indexPath.row == 0 || indexPath.row == activeItem.count + 1 {
            return false
        }
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = getItem(indexPath) as NSDictionary
            Bakkle.sharedInstance.removeItem(item.valueForKey("pk")!.integerValue, success: {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.removeAtIndex(indexPath)
                    self.classifyData()
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    tableView.reloadData()
                })
            }, fail: {})
            
        }
    }
    
    func noInternetConnectionAlert(){
        var alert = UIAlertController(title: "No Internet", message: "There was an error! Please check your Network Connection and try again", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
}
