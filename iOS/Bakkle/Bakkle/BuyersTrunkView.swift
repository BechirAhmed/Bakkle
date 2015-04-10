//
//  BuyersTrunkView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class BuyersTrunkView: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func btnAddItem(sender: AnyObject) {
        // Probably a seque instead
    }
    
}
