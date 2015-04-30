//
//  FeedFilter.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class FeedFilterView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBOutlet weak var distance: UISlider!
    @IBOutlet weak var price: UISlider!
    @IBOutlet weak var number: UISlider!
    
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!

    
    @IBAction func filterChanged(sender: AnyObject) {
        println("d:\(Int(distance.value)) p:\(price.value) n: \(number.value)")
        distanceLbl.text = "\(Int(distance.value)) mi"
        priceLbl.text = "$\(Int(price.value))"
        numberLbl.text = "\(Int(number.value))"
        if number.value >= 1000 {
            numberLbl.text = "∞"
            Bakkle.sharedInstance.setFilter(distance.value, ffilter_price:price.value, ffilter_number:9999)
        } else {
            Bakkle.sharedInstance.setFilter(distance.value, ffilter_price:price.value, ffilter_number:number.value)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        distance.value = Bakkle.sharedInstance.filter_distance
        price.value = Bakkle.sharedInstance.filter_price
        number.value = Bakkle.sharedInstance.filter_number
        
        distance.maximumValue = 100
        distance.maximumTrackTintColor = UIColor.blackColor()
        distance.thumbTintColor = UIColor.blackColor()
        distance.minimumTrackTintColor = UIColor.blackColor()
        distance.setThumbImage(UIImage(named: "dot.png"), forState: UIControlState.Normal)
        distance.setThumbImage(UIImage(named: "dot.png"), forState: UIControlState.Highlighted)

        price.maximumValue = 100
        price.maximumTrackTintColor = UIColor.blackColor()
        price.thumbTintColor = UIColor.blackColor()
        price.minimumTrackTintColor = UIColor.blackColor()
        price.setThumbImage(UIImage(named: "dot.png"), forState: UIControlState.Normal)
        price.setThumbImage(UIImage(named: "dot.png"), forState: UIControlState.Highlighted)

        number.maximumValue = 1000
        number.maximumTrackTintColor = UIColor.blackColor()
        number.thumbTintColor = UIColor.blackColor()
        number.minimumTrackTintColor = UIColor.blackColor()
        number.setThumbImage(UIImage(named: "dot.png"), forState: UIControlState.Normal)
        number.setThumbImage(UIImage(named: "dot.png"), forState: UIControlState.Highlighted)
        number.enabled = true

    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
}

