//
//  CollectionThumbnail.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/29/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class CollectionThumbnail: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    func setThumbnailImage(thumbnailImage: UIImage) {
        self.imgView.image = thumbnailImage
    }
}
