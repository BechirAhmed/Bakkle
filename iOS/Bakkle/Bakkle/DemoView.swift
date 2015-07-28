//
//  DemoView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 5/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class DemoView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var serverSelect: UIPickerView!
    @IBOutlet weak var currentServer: UILabel!
    
    override func viewDidLoad() {
        setupButtons()
        
        if(Bakkle.sharedInstance.flavor == 2){
            self.view.backgroundColor = Bakkle.sharedInstance.theme_base
        }
        
        serverSelect.delegate = self
        serverSelect.dataSource = self
        
        serverSelect.selectRow(NSUserDefaults.standardUserDefaults().integerForKey("server"), inComponent: 0, animated: true)
        currentServer.text = Bakkle.serverNames[NSUserDefaults.standardUserDefaults().integerForKey("server")]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Bakkle.servers.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return Bakkle.serverNames[row]
    }
    
    func setupButtons() {
        menuBtn.setImage(IconImage().menu(), forState: .Normal)
        menuBtn.setTitle("", forState: .Normal)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentServer.text = Bakkle.serverNames[row]
        NSUserDefaults.standardUserDefaults().setInteger(row, forKey: "server")
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