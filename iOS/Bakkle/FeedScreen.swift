//
//  FeedScreen.swift
//  Bakkle
//
//  Created by Ishank Tandon on 3/18/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class FeedScreen: UIViewController, MDCSwipeToChooseDelegate {

    var state : MDCPanState!
    
    let menuSegue = "presentNav"
    
    var transitionOperator = TransitionOperator()
    
    
    
    @IBOutlet weak var drawer: UIView!
    

    @IBAction func menuButtonPressed(sender: AnyObject) {
        drawer.frame.origin = CGPoint(x: 0, y: 0)
    }
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var shortImg = UIImageView(image: UIImage(named: "bakkleLogo.png")) //UIImage(named: "bakkleLogo.png")
        self.navBar.backgroundColor = UIColor.redColor()
        self.navBar.topItem?.title = "Logo goes here!"
        
       // self.navigationItem.leftBarButtonItem = UINavigationItem.to
        
        var options = MDCSwipeToChooseViewOptions()
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
        
        let view : MDCSwipeToChooseView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
        
        view.imageView.image = UIImage(named: "photo")
        self.view.addSubview(view)
    }
    
//    @IBAction func presentMenuBar(sender: AnyObject) {
//        performSegueWithIdentifier(menuSegue, sender: self)
//    }
    
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
            println("Meh!!!")
        }
        else if direction == MDCSwipeDirection.Right {
            println("I want")
        }
        else if direction == MDCSwipeDirection.Up {
            println("HOLD!")
        }
        else if direction == MDCSwipeDirection.Down {
            println("Report")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == menuSegue {
            let toViewController = segue.destinationViewController as Menu
            self.modalPresentationStyle = UIModalPresentationStyle.Custom
            toViewController.transitioningDelegate = self.transitionOperator
        }
    }
    
    
    
    
}
