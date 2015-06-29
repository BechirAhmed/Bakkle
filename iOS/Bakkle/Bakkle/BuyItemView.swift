//
//  BuyItemView.swift
//  Bakkle
//
//  Created by Carroll, Joseph B on 6/29/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class BuyItemView: UIViewController {
    
    @IBOutlet weak var sellerImage: UIImageView!
    @IBAction func btnBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}