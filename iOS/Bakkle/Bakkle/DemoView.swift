//
//  DemoView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 5/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class DemoView: UIViewController {
    
    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        setupButtons()
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    

    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    @IBAction func btnReset(sender: AnyObject) {
        Bakkle.sharedInstance.resetDemo({
            
            let alertController = UIAlertController(title: "Bakkle Server", message:
                "Items in the feed have been reset for DEMO.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        })
    }
}