//
//  FeedFilter.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class FeedFilterView: UIViewController {
    
    @IBOutlet weak var distance: UISlider!
    @IBOutlet weak var price: UISlider!
    @IBOutlet weak var number: UISlider!
    
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    override func viewWillAppear(animated: Bool) {
        
        /* Custom skin for UISlideView */
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

        distance.setValue(Bakkle.sharedInstance.filter_distance, animated: true)
        price.setValue(Bakkle.sharedInstance.filter_price, animated: true)
        number.setValue(Bakkle.sharedInstance.filter_number, animated: true)
        
        self.filterRealtime(0) // force labels to update
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    /* FILTER CONTROLS */
    @IBAction func filterRealtime(sender: AnyObject) {
        //println("d:\(Int(distance.value)) p:\(price.value) n: \(number.value)")
        if distance.value >= 100 {
            distanceLbl.text = "100+ mi"
        } else {
            distanceLbl.text = "\(Int(distance.value)) mi"
        }
        priceLbl.text = "$\(Int(price.value))"
        numberLbl.text = "\(Int(number.value))"
        if number.value >= 1000 {
            numberLbl.text = "∞"
        } else {
        }
    }
    @IBAction func filterChanged(sender: AnyObject) {
        println("SET d:\(Int(distance.value)) p:\(price.value) n: \(number.value)")
        if distance.value >= 100 {
            distanceLbl.text = "100+ mi"
        } else {
            distanceLbl.text = "\(Int(distance.value)) mi"
        }
        priceLbl.text = "$\(Int(price.value))"
        numberLbl.text = "\(Int(number.value))"
        if number.value >= 1000 {
            numberLbl.text = "∞"
            Bakkle.sharedInstance.setFilter(distance.value, ffilter_price:price.value, ffilter_number:9999)
        } else {
            Bakkle.sharedInstance.setFilter(distance.value, ffilter_price:price.value, ffilter_number:number.value)
        }
    }

}

