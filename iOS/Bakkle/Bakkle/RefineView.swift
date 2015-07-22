//
//  FeedFilter.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/9/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class RefineView: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var distance: UISlider!
    @IBOutlet weak var price: UISlider!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    var parentView: FeedView!
    var search_text: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.clearColor()
        setupBackground()
        
        setupButtons()
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        if search_text != nil {
            searchBar.text = search_text
        }
    }

    override func viewWillAppear(animated: Bool) {
    
        distance.setValue(Bakkle.sharedInstance.filter_distance, animated: true)
        price.setValue(Bakkle.sharedInstance.filter_price, animated: true)
        
        self.filterRealtime(0) // force labels to update
        
        self.searchBar.barTintColor = UIColor.clearColor()
        self.searchBar.backgroundImage = UIImage()
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    /* UISearch Bar delegate */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.parentView.searchBar.text = searchText
        self.parentView.searchBar(self.parentView.searchBar, textDidChange: searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.parentView.requestUpdates()
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.parentView.requestUpdates()
        searchBar.resignFirstResponder()
    }
    /* End search bar delegate */
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissKeyboard()
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
        self.dismissKeyboard()
        if distance.value >= 100 {
            distanceLbl.text = "∞"
        } else {
            distanceLbl.text = "\(Int(distance.value)) mi"
        }
        if price.value >= 100 {
            priceLbl.text = "∞"
        } else {
            priceLbl.text = "$\(Int(price.value))"
        }
    }
    
    @IBAction func filterChanged(sender: AnyObject) {
        println("SET d:\(Int(distance.value)) p:\(price.value)")
        self.dismissKeyboard()
        if distance.value >= 100 {
            distanceLbl.text = "∞"
        } else {
            distanceLbl.text = "\(Int(distance.value)) mi"
        }
        if price.value >= 100 {
            priceLbl.text = "∞"
        } else {
            priceLbl.text = "$\(Int(price.value))"
        }
        Bakkle.sharedInstance.setFilter(distance.value, ffilter_price:price.value)
        self.parentView.requestUpdates()
    }

}

