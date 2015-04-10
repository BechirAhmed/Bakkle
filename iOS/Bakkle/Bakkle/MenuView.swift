//
//  MenuView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class MenuView: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        println(Bakkle.sharedInstance.apiVersion)
        
        /* Reveal */
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    /* MENU ITEMS */
    @IBAction func btnSellersGarage(sender: AnyObject) {
//        Bakkle.sharedInstance.resetDemo()
    }
    
    @IBAction func btnBuyersTrunk(sender: AnyObject) {
  //      Bakkle.sharedInstance.resetDemo()
    }
    
    @IBAction func btnHoldingPattern(sender: AnyObject) {
  //      Bakkle.sharedInstance.resetDemo()
    }
    
    @IBAction func btnFeedFilter(sender: AnyObject) {
   //     Bakkle.sharedInstance.resetDemo()
    }
    
    @IBAction func btnSettings(sender: AnyObject) {
  //      Bakkle.sharedInstance.resetDemo()
    }

    @IBAction func btnReset(sender: AnyObject) {
   //     Bakkle.sharedInstance.resetDemo()
    }

    @IBAction func btnLogout(sender: AnyObject) {
        Bakkle.sharedInstance.logout()
        FBSession.activeSession().closeAndClearTokenInformation()
        self.revealViewController().dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
}
