//
//  ListItemCell.swift
//  Bakkle
//
//  Created by Carroll, Joseph B on 6/3/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ListItemCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func didMoveToSuperview() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}