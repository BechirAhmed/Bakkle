//
//  FeedScreen.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/18/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import UIKit

class FeedScreen: UIViewController, MDCSwipeToChooseDelegate {

    var state : MDCPanState!
    
    let menuSegue = "presentNav"
    
    let options = MDCSwipeToChooseViewOptions()
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var addItemBtn: UIButton!
    
    @IBOutlet weak var drawer: UIView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    var hardCoded = false
    
    var item_id = 42 //TODO: unhardcode this
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    @IBAction func btnX(sender: AnyObject) {
        Bakkle.sharedInstance.markItem("meh", item_id: self.item_id, success: {}, fail: {})

    }
    @IBAction func btnCheck(sender: AnyObject) {
        Bakkle.sharedInstance.markItem("want", item_id: self.item_id, success: {}, fail: {})
    }
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        progressIndicator.startAnimating()
        
        options.delegate = self
        options.likedText = "Want"
        options.likedColor = UIColor.greenColor()
        options.nopeText = "Meh"
        options.holdText = "Hold"
        options.holdColor = UIColor.blueColor()
        options.onPan = {(state) in
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
                println("let go to delete the picture.")
            }
        }
        
        /* Menu reveal */
        if self.revealViewController() != nil {
            menuBtn.targetForAction("revealToggle:", withSender: self)
            self.revealViewController().rearViewRevealWidth = 250
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        let view : MDCSwipeToChooseView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
        
        if hardCoded {
            view.imageView.image = UIImage(named: "item-lawnmower.png")
            view.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.view.addSubview(view)
        } else {
            Bakkle.sharedInstance.populateFeed({
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateView(view)
                }
            })
        }
    }
    
    func showAddItem(){
        var addItem: UIViewController = AddItem()
        presentViewController(addItem, animated: true, completion: nil)
    }
    
    func updateView(feedView: MDCSwipeToChooseView) {
        if hardCoded {
            feedView.imageView.image = UIImage(named: "item-lawnmower.png")
            feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            view.addSubview(feedView)
        } else {
            if Bakkle.sharedInstance.feedItems.count > 0 {
                var topItem = Bakkle.sharedInstance.feedItems[0]
                var bottomItem = Bakkle.sharedInstance.feedItems[1]
                println("top item is: \(topItem)")
                
                var itemDetails: NSDictionary = topItem.valueForKey("fields") as! NSDictionary!
                var bottomItemDetail: NSDictionary = bottomItem.valueForKey("fields") as! NSDictionary!
                
                let imgURLs: String = itemDetails.valueForKey("image_urls") as! String
                let bottomURL: String = bottomItemDetail.valueForKey("image_urls") as! String
                
                println("urls are: \(imgURLs)")
                let imgURL = NSURL(string: imgURLs)
                if let imgData = NSData(contentsOfURL: imgURL!) {
                    feedView.imageView.image = UIImage(data: imgData)
                    feedView.imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    self.view.addSubview(feedView)
                }
            }
        }
    }
    
    func viewDidCancelSwipe(view: UIView!) {
        println("You canceled the swipe")
    }
    
    func view(view: UIView!, shouldBeChosenWithDirection direction: MDCSwipeDirection) -> Bool {
        if direction == MDCSwipeDirection.Left || direction == MDCSwipeDirection.Right || direction == MDCSwipeDirection.Up || direction == MDCSwipeDirection.Down {
            return true
        } else {
            UIView.animateWithDuration(0.16, animations: { () -> Void in
                view.transform = CGAffineTransformIdentity
                var superView : UIView = self.view.superview!
                self.view.center = superView.convertPoint(superView.center, fromView: superView.superview)
            })
            return false
        }
    }
    
    func view(view: UIView!, wasChosenWithDirection direction: MDCSwipeDirection) {
        if direction == MDCSwipeDirection.Left {
            Bakkle.sharedInstance.markItem("meh", item_id: self.item_id, success: {}, fail: {})
        }
        else if direction == MDCSwipeDirection.Right {
            Bakkle.sharedInstance.markItem("want", item_id: self.item_id, success: {}, fail: {})
        }
        else if direction == MDCSwipeDirection.Up {
            Bakkle.sharedInstance.markItem("hold", item_id: self.item_id, success: {}, fail: {})
        }
        else if direction == MDCSwipeDirection.Down {
            Bakkle.sharedInstance.markItem("report", item_id: self.item_id, success: {}, fail: {})
        }
    }
    
}
