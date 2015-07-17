//
//  MenuTableView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class MenuTableController: UITableViewController {

    let profileSegue = "PushToProfileView"
    var backView: UIView!
    var segueNotifier: dispatch_semaphore_t = dispatch_semaphore_create(0)
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feedImg: UIImageView!
    @IBOutlet weak var sellerImg: UIImageView!
    @IBOutlet weak var buyerImg: UIImageView!
    @IBOutlet weak var holdImg: UIImageView!
    @IBOutlet weak var contactImg: UIImageView!
    @IBOutlet weak var profileBtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Reveal */
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        setupImages()
        setupBackground()
        setupProfileLabel()
        profileBtn.image = IconImage().settings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.userInteractionEnabled = true
        
        /* set up the function of pushing back frontViewController when tapped frontViewController */
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            backView = UIView(frame: self.revealViewController().frontViewController.view.frame)
            self.revealViewController().frontViewController.view.addSubview(backView)
            self.revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
        setupProfileImg()
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
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
        self.feedImg.image = IconImage().home()
        self.sellerImg.image = IconImage().edit()
        self.buyerImg.image = IconImage().cart()
        self.holdImg.image = IconImage().down()
        self.contactImg.image = IconImage().contact()
    }
    
    func setupBackground() {
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = tableView.bounds
        var backgroundImageView = UIImageView(frame: tableView.bounds)
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.hnk_setImageFromURL(Bakkle.sharedInstance.profileImgURL!)
        backgroundImageView.clipsToBounds = true
        backgroundImageView.addSubview(visualEffectView)
        tableView.backgroundView = backgroundImageView
    }
    
    func setupProfileImg() {
        self.profileImg.hnk_setImageFromURL(Bakkle.sharedInstance.profileImgURL!)
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width/2
        self.profileImg.layer.borderWidth = 5.0
        self.profileImg.clipsToBounds = true
        let borderColor = UIColor.whiteColor()
        self.profileImg.layer.borderColor = borderColor.CGColor
    }
    
    func setupProfileLabel() {
        self.nameLabel.text = Bakkle.sharedInstance.first_name + " " + Bakkle.sharedInstance.last_name
    }
    
    @IBAction func btnContact(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.bakkle.com/")!)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        /* This fixes the small lines on the left hand side of the cell dividers */
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.userInteractionEnabled = false
        if segue.identifier == self.profileSegue {
            let destinationVC = segue.destinationViewController as! ProfileView
            Bakkle.sharedInstance.getAccount(Bakkle.sharedInstance.account_id, success: {
                destinationVC.user = Bakkle.sharedInstance.responseDict
                dispatch_semaphore_signal(self.segueNotifier)
            }, fail: {})
            dispatch_semaphore_wait(segueNotifier, DISPATCH_TIME_FOREVER)
        }
    }
}



