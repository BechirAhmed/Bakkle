//
//  EmailRequiredView.swift
//  Bakkle
//
//  Created by Barr, Patrick T on 7/31/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import UIKit

class EmailRequiredView: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Bakkle.sharedInstance.flavor == Bakkle.GOODWILL ){
            self.logo.image = UIImage(named: "GWLogo_Full@2x.png")!
            logo.contentMode = UIViewContentMode.ScaleAspectFit
            self.background.image = UIImage(named: "LoginScreen-bkg-blue.png")!
        }
    }
    
    @IBAction func facebookAppPermissions(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/help/iphone-app/218345114850283?rdrhc")!)
    }
    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

