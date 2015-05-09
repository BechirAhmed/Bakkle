//
//  HoldingPattern.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit
import Haneke

class HoldingPatternView: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        Bakkle.sharedInstance.populateHolding({
            //            updateUI()
        });
    }

}
