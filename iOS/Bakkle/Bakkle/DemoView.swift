//
//  DemoView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 5/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class DemoView: UIViewController {

    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func btnTestImage(sender: AnyObject) {
//        Bakkle.sharedInstance.postImage(UIImage(named: "tiger.jpg")!)
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