//
//  FeedFilter.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class RefineView: UIViewController {
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var distance: UISlider!
    @IBOutlet weak var price: UISlider!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.clearColor()
        setupBackground()
        
        setupButtons()
        
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

        distance.setValue(Bakkle.sharedInstance.filter_distance, animated: true)
        price.setValue(Bakkle.sharedInstance.filter_price, animated: true)
        
        self.filterRealtime(0) // force labels to update
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().close(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    func setupBackground() {
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = self.view.bounds
        self.view.addSubview(visualEffectView)
    }
    
    /* MENUBAR ITEMS */
    @IBAction func btnMenu(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* FILTER CONTROLS */
    @IBAction func filterRealtime(sender: AnyObject) {
        //println("d:\(Int(distance.value)) p:\(price.value) n: \(number.value)")
        if distance.value >= 100 {
            distanceLbl.text = "100+ mi"
        } else {
            distanceLbl.text = "\(Int(distance.value)) mi"
        }
        if price.value >= 100 {
            priceLbl.text = "$100+"
        } else {
            priceLbl.text = "$\(Int(price.value))"
        }
    }
    @IBAction func filterChanged(sender: AnyObject) {
        println("SET d:\(Int(distance.value)) p:\(price.value)")
        if distance.value >= 100 {
            distanceLbl.text = "100+ mi"
        } else {
            distanceLbl.text = "\(Int(distance.value)) mi"
        }
        if price.value >= 100 {
            priceLbl.text = "$100+"
        } else {
            priceLbl.text = "$\(Int(price.value))"
        }
        Bakkle.sharedInstance.setFilter(distance.value, ffilter_price:price.value)
    }

}

