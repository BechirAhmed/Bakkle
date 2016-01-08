//
//  TutorialCell.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 1/8/16.
//  Copyright (c) 2016 Bakkle. All rights reserved.
//

import Foundation

class TutorialCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    @IBOutlet weak var button: UIButton!
    
    override func didMoveToSuperview() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}