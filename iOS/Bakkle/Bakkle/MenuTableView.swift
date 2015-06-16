//
//  MenuTableView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class MenuTableController: UITableViewController {
    
    var backView: UIView!
    
    @IBOutlet weak var feedLbl: UILabel!
    @IBOutlet weak var garageLbl: UILabel!
    @IBOutlet weak var trunkLbl: UILabel!
    @IBOutlet weak var holdingLbl: UILabel!
    @IBOutlet weak var filterLbl: UILabel!
    @IBOutlet weak var settingsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Reveal */
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        setupImages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* set up the function of pushing back frontViewController when tapped frontViewController */
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            backView = UIView(frame: self.revealViewController().frontViewController.view.frame)
            //backView.backgroundColor = UIColor(red: CGFloat(1.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0))
            self.revealViewController().frontViewController.view.addSubview(backView)
            self.revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.revealViewController() != nil {
           backView.removeFromSuperview()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupImages() {
        self.feedLbl.attributedText = stringWithIcon("FEED", image: IconImage().home())
        self.garageLbl.attributedText = stringWithIcon("SELLER'S GARAGE", image: IconImage().edit())
        self.trunkLbl.attributedText = stringWithIcon("BUYER'S TRUNK", image: IconImage().cart())
        self.holdingLbl.attributedText = stringWithIcon("HOLDING PATTERN", image: IconImage().down())
        self.filterLbl.attributedText = stringWithIcon("FEED FILTER", image: IconImage().filter())
        self.settingsLbl.attributedText = stringWithIcon("SETTINGS", image: IconImage().settings())
    }
    
    func stringWithIcon(label: String, image: UIImage) -> NSAttributedString {
        var attachment: OffsetTextAttachment = OffsetTextAttachment()
        let font: UIFont = self.feedLbl.font
        attachment.fontDescender = font.descender
        attachment.image = image
        
        var attachmentString : NSAttributedString = NSAttributedString(attachment: attachment)
        var stringFinal : NSMutableAttributedString = NSMutableAttributedString(string: " " + label)
        stringFinal.insertAttributedString(attachmentString, atIndex: 0)
        
        return stringFinal
    }
    
    @IBAction func btnReset(sender: AnyObject) {
        Bakkle.sharedInstance.resetDemo({
            
            let alertController = UIAlertController(title: "Bakkle Server", message:
                "Items in the feed have been reset for DEMO.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        })
    }
    
    @IBAction func btnLogout(sender: AnyObject) {
        Bakkle.sharedInstance.logout()
        FBSession.activeSession().closeAndClearTokenInformation()
        self.revealViewController().dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        /* This fixes the small lines on the left hand side of the cell dividers */
        cell.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
    }
}



