//
//  MainWebView.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/1/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import WebKit

class MainWebView: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var myWebView : WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadAddress()
        println("WebView is loading? \(self.webView.loading)")
    }

    func loadAddress(){
        let targetURL = NSURL(string: "http//google.com")
        let request = NSURLRequest(URL: targetURL!)
        webView.loadRequest(request)
        webView.sizeToFit()
    }
    
    override func viewDidAppear(animated: Bool) {
        loadAddress()
    }

}
