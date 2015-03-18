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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var options : MDCSwipeToChooseViewOptions = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.likedText = "Want"
        options.likedColor = UIColor.greenColor()
        options.nopeText = "Meh"
//        options.onPan = {
  //          if state.thresholdRatio == 1.f && state.direction == MDCSwipeDirection.Left){
    //            println("let go to delete the picture.")
      //      }
       // }
        
        let view : MDCSwipeToChooseView = MDCSwipeToChooseView(frame: self.view.bounds, options: options)
        
        view.imageView.image = UIImage(named: "photo")
        self.view.addSubview(view)
    }
    
    func viewDidCancelSwipe(view: UIView!) {
        println("You canceled the swipe")
    }
    
    func view(view: UIView!, shouldBeChosenWithDirection direction: MDCSwipeDirection) -> Bool {
        if direction == MDCSwipeDirection.Left {
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
    }
    
    
    
    
    
}
