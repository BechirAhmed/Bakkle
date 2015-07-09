//
//  CameraView.swift
//  Bakkle
//
//  Created by Barr, Patrick T on 7/8/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import Foundation

class CameraView: UIViewController {
    @IBOutlet weak var capButtonOutline: UIView!
    @IBOutlet weak var capButtonSpace: UIView!
    @IBOutlet weak var capButton: UIButton!
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        capButtonOutline.layer.cornerRadius = capButtonOutline.layer.frame.size.width / 2
        capButtonSpace.layer.cornerRadius = capButtonSpace.layer.frame.size.width / 2
        capButton.layer.cornerRadius = capButton.layer.frame.size.width / 2
        capButtonOutline.layer.masksToBounds = true
        capButtonSpace.layer.masksToBounds = true
        capButton.layer.masksToBounds = true
        
        // notes on the button names
        // SC = switch camera
        // ... (gallery)  = gallery
        // everything should scale with height (other than status bar, that is static height)
    }
}