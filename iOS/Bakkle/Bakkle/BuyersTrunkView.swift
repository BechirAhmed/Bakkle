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
}

class BuyersTrunkView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    let statusCellIdentifier = "StatusCell"
    var activeItem: [Int]!
    var boughtItem: [Int]!
    var soldItem: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Bakkle.sharedInstance.flavor == Bakkle.GOODWILL){
            self.view.backgroundColor = Bakkle.sharedInstance.theme_base
        }
        
        // display status bar every time the screen shows up
        UIApplication.sharedApplication().statusBarHidden = false
        
        setupButtons()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        
        self.tableView.tableFooterView = UIView()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        var observer = notificationCenter.addObserverForName(Bakkle.bkTrunkUpdate, object: nil, queue: mainQueue) { _ in
            self.classifyData()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.view.userInteractionEnabled = true
        
        classifyData()
        
        Bakkle.sharedInstance.populateTrunk({})
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    // helper function
    func getItem(indexPath: NSIndexPath) -> NSDictionary {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            let item = Bakkle.sharedInstance.trunkItems[activeItem[indexPath.row-1]] as! NSDictionary
            return item
        }else if indexPath.row > activeItem.count+1 && indexPath.row <= activeItem.count+boughtItem.count+1 {
            let item = Bakkle.sharedInstance.trunkItems[boughtItem[indexPath.row-2-activeItem.count]] as! NSDictionary
            return item
        }else {
            let item = Bakkle.sharedInstance.trunkItems[soldItem[indexPath.row-3-activeItem.count-boughtItem.count]] as! NSDictionary
            return item
        }
    }
    
    func removeAtIndex(indexPath: NSIndexPath) {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            Bakkle.sharedInstance.trunkItems.removeAtIndex(activeItem[indexPath.row-1])
        }else if indexPath.row > activeItem.count+1 && indexPath.row <= activeItem.count+boughtItem.count+1 {
            Bakkle.sharedInstance.trunkItems.removeAtIndex(boughtItem[indexPath.row-2-activeItem.count])
        }else {
            Bakkle.sharedInstance.trunkItems.removeAtIndex(soldItem[indexPath.row-3-activeItem.count-boughtItem.count])
        }
    }
    
    func getIndex(indexPath: NSIndexPath) -> Int {
        if indexPath.row > 0 && indexPath.row <= activeItem.count {
            return activeItem[indexPath.row-1]
        }else if indexPath.row > activeItem.count+1 && indexPath.row <= activeItem.count+boughtItem.count+1 {
            return boughtItem[indexPath.row-2-activeItem.count]
        }else {
            return soldItem[indexPath.row-3-activeItem.count-boughtItem.count]
        }

    }
    
    func classifyData() {
        self.activeItem = [Int]()
        self.boughtItem = [Int]()
        self.soldItem = [Int]()
        if Bakkle.sharedInstance.trunkItems == nil || Bakkle.sharedInstance.trunkItems.count == 0 {
            return
        }
        for index in 0...Bakkle.sharedInstance.trunkItems.count-1 {
            let item = Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as? NSDictionary
            let status = item?.valueForKey("status") as! String
            switch status {
            case "Active":
                self.activeItem.append(index)
                break
            case "Sold":
                if Bakkle.sharedInstance.trunkItems[index].valueForKey("sale") != nil {
                    self.boughtItem.append(index)
                }else {
                    self.soldItem.append(index)
                }
                break
            default: break
            }
        }

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == activeItem.count + 1 || indexPath.row == activeItem.count + boughtItem.count + 2 {
            return 30.0
        }
        return 100.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeItem == nil || boughtItem == nil || soldItem == nil {
            return 0
        }
        if activeItem.count != 0 || boughtItem.count != 0 || soldItem.count != 0 {
            println("Actually got items from the trunk!")
            println(String(Bakkle.sharedInstance.trunkItems.count) + " items in trunk")
            return activeItem.count + soldItem.count + boughtItem.count + 3
        }
        println("Didn't get anything in trunk")
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
        }
        if indexPath.row == activeItem.count + 1 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Bought (\(boughtItem.count))"
            cell.statusLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        if indexPath.row == activeItem.count + boughtItem.count + 2 {
            let cell : StatusCell = tableView.dequeueReusableCellWithIdentifier(self.statusCellIdentifier, forIndexPath: indexPath) as! StatusCell
            cell.statusLabel.text = "Expired (\(soldItem.count))"
            cell.statusLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }


        println("[BuyersTrunk] Updating table view")
        let cell = self.tableView.dequeueReusableCellWithIdentifier("BuyersTrunkCell") as! BuyersTrunkCell
        cell.itemImage?.image = UIImage(named: "blank.png")
        cell.itemImage?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.itemImage?.layer.cornerRadius = 10.0
        cell.itemImage?.clipsToBounds = true
        
        let trunkEntry : NSDictionary = getItem(indexPath)
        let item = trunkEntry.valueForKey("item") as! NSDictionary
        println(item.description)
        let imgURLs : [String] = item.valueForKey("image_urls") as! [String]
        let description : String = item.valueForKey("description") as! String
        let title : String = item.valueForKey("title") as! String
        let price : String = item.valueForKey("price") as! String
        let firstURL = imgURLs[0] as String
        let imgURL = NSURL(string: firstURL)
            
        cell.itemImage!.hnk_setImageFromURL(imgURL!)
        cell.itemImage!.userInteractionEnabled = true
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        cell.itemImage!.addGestureRecognizer(tapGestureRecognizer)
        cell.itemImage!.tag = getIndex(indexPath)
        cell.titleLabel!.text = title.uppercaseString
        cell.priceLabel!.text = "$" + price
      
        return cell
    }
    
    func imageTapped(sender: UITapGestureRecognizer){
        if !Bakkle.sharedInstance.isInternetConnected() {
            self.noInternetConnectionAlert()
            return
        }
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ItemDetails = sb.instantiateViewControllerWithIdentifier("ItemDetails") as! ItemDetails
        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        vc.item = Bakkle.sharedInstance.trunkItems[sender.view!.tag].valueForKey("item") as! NSDictionary
        let status = vc.item.valueForKey("status") as! String
        if status == "Sold" {
            vc.available = false
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !Bakkle.sharedInstance.isInternetConnected() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.noInternetConnectionAlert()
            return
        }
        if indexPath.row == 0 || indexPath.row == activeItem.count + 1 || indexPath.row == activeItem.count + boughtItem.count + 2 {
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if Bakkle.sharedInstance.account_type == 0 {
            let vc = sb.instantiateViewControllerWithIdentifier("loginView") as! LoginView
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
            let buyer = User(facebookID: Bakkle.sharedInstance.facebook_id_str,accountID: Bakkle.sharedInstance.account_id,
                firstName: Bakkle.sharedInstance.first_name, lastName: Bakkle.sharedInstance.last_name)
            let chatItem = getItem(indexPath).valueForKey("item") as! NSDictionary
            let chatItemId = (chatItem.valueForKey("pk") as! NSNumber).stringValue
            var chatPayload: WSRequest = WSStartChatRequest(itemId: chatItemId)
            chatPayload.successHandler = {
                (var success: NSDictionary) in
                let chatId = success.valueForKey("chatId") as! Int
                var buyerChat = Chat(user: buyer, lastMessageText: "", lastMessageSentDate: NSDate(), chatId: chatId)
                let chatViewController = ChatViewController(chat: buyerChat)
                chatViewController.item = chatItem
                chatViewController.seller = chatItem.valueForKey("seller") as! NSDictionary
                chatViewController.isBuyer = true
                self.navigationController?.pushViewController(chatViewController, animated: true)
            }
            WSManager.enqueueWorkPayload(chatPayload)
            self.view.userInteractionEnabled = false
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if !Bakkle.sharedInstance.isInternetConnected() {
           return false
        }
        if indexPath.row == 0 || indexPath.row == activeItem.count + 1 || indexPath.row == activeItem.count + boughtItem.count + 2 {
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
    
    func noInternetConnectionAlert(){
        var alert = UIAlertController(title: "No Internet", message: "There was an error! Please check your Network Connection and try again", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
}
