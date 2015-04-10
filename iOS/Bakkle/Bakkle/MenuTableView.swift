//
//  MenuTableView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class MenuTableController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Reveal */
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}



