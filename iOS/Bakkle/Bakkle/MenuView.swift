//
//  MenuView.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 4/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class MenuView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Reveal */
        if self.revealViewController() != nil {
//            menuButton.target = self.revealViewController()
//            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func btnReset(sender: AnyObject) {
        self.resetDemo()
    }

    
    let baseUrlString : String = "https://app.bakkle.com/"
    
    /* Reset server */
    func resetDemo(){
        
        let url:NSURL? = NSURL(string: baseUrlString.stringByAppendingString("items/reset/"))
        let request = NSMutableURLRequest(URL: url!)
        var postString : String = "account_id=\(42)" //TODO: Grab account_id from global
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            var error: NSError? = error
            
            var responseDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as NSDictionary!
            
            if responseDict.valueForKey("status")?.integerValue == 1 {
                // Success
            }
        }
        task.resume()
}
}

    
