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
    var user: NSDictionary!
    
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
        profileBtn.image = IconImage().settings()
        self.tableView.tableFooterView = UIView()
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
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
        setupProfileImg()
        setupBackground()
        setupProfileLabel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
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
        if Bakkle.sharedInstance.account_type == 0 || Bakkle.sharedInstance.profileImgURL == nil  {
            backgroundImageView.image = UIImage(named: "default_profile")
        }else{
            backgroundImageView.hnk_setImageFromURL(Bakkle.sharedInstance.profileImgURL!)
        }
        
        backgroundImageView.clipsToBounds = true
        backgroundImageView.addSubview(visualEffectView)
        tableView.backgroundView = backgroundImageView
    }
    
    func setupProfileImg() {
        if Bakkle.sharedInstance.account_type == 0 || Bakkle.sharedInstance.profileImgURL == nil {
            self.profileImg.image = UIImage(named: "default_profile")
        }else{
            self.profileImg.hnk_setImageFromURL(Bakkle.sharedInstance.profileImgURL!)
        }
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width/2
        self.profileImg.layer.borderWidth = 5.0
        self.profileImg.clipsToBounds = true
        let borderColor = UIColor.whiteColor()
        self.profileImg.layer.borderColor = borderColor.CGColor
    }
    
    func setupProfileLabel() {
        if Bakkle.sharedInstance.account_type == 0 || Bakkle.sharedInstance.first_name == nil || Bakkle.sharedInstance.last_name == nil {
            self.nameLabel.text = "Guest"
        }else{
            self.nameLabel.text = Bakkle.sharedInstance.first_name + " " + Bakkle.sharedInstance.last_name
        }
    }
    
    @IBAction func btnContact(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: (Bakkle.sharedInstance.flavor == Bakkle.GOODWILL ? "http://www.goodwill.org/" : "http://www.bakkle.com/"))!)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        /* This fixes the small lines on the left hand side of the cell dividers */
        cell.backgroundColor = UIColor.clearColor()
        if (indexPath.row == 2 && Bakkle.sharedInstance.flavor == Bakkle.GOODWILL) || (indexPath.row == 6 && !Bakkle.developerTools) {
            cell.hidden = true
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Bakkle.developerTools {
            return 5
        }
        return 6
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 177
        }
        if (indexPath.row == 2 && Bakkle.sharedInstance.flavor == Bakkle.GOODWILL) {
            return 0
        }
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.view.userInteractionEnabled = false
            if Bakkle.sharedInstance.account_type == 0 {
                self.performSegueWithIdentifier(self.profileSegue, sender: self)
            }else{
                Bakkle.sharedInstance.getAccount(Bakkle.sharedInstance.account_id, success: {
                    self.user = Bakkle.sharedInstance.responseDict.valueForKey("account") as! NSDictionary
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier(self.profileSegue, sender: self)
                    })
                    }, fail: {})
            }
            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.userInteractionEnabled = false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        if segue.identifier == self.profileSegue {
            let destinationVC = segue.destinationViewController as! ProfileView
            if self.user != nil {
                destinationVC.user = self.user
            }
        }
    }
}



