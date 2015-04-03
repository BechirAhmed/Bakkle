//
//  MainWebView.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/1/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import WebKit

class MainWebView: UIViewController,UIWebViewDelegate {
    
    let mainURL = "https://app.bakkle.com/p1/comp.html"

    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func logout(sender: AnyObject) {
        FBSession.activeSession().closeAndClearTokenInformation()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadAddress()
    }

    func loadAddress(){
        let targetURL = NSURL(string: mainURL)
        let request = NSURLRequest(URL: targetURL!)
        webView.loadRequest(request)
        //webView.sizeToFit()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println(true)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        println("web view started loading!!!!!!!")
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println("loading failed!!!! Ugghhh!! \(error)")
    }

}
