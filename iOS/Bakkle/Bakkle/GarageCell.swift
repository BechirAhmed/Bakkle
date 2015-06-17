//
//  CollectionThumbnail.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/29/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class GarageCell: UICollectionViewCell {
    

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var numHold: UILabel!
    @IBOutlet weak var numNope: UILabel!
    @IBOutlet weak var numLike: UILabel!
    @IBOutlet weak var numComment: UILabel!
    @IBOutlet weak var numViews: UILabel!
    
    func setThumbnailImage(thumbnailImage: UIImage) {
        self.imgView.image = thumbnailImage
    }
}
