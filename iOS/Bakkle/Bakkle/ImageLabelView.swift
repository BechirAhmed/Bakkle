//
//  ImageLabelView.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/15/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ImageLabelView: UIView {
    
    var imageView: UIImageView!
    var label: UILabel!
        
    init(){
        super.init(frame: CGRectZero)
        imageView = UIImageView()
        label = UILabel()
    }
        
    init(frame: CGRect, image: UIImage, text: NSString) {
        super.init(frame: frame)
        constructImageView(image)
        constructLabel(text)
    }
        
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func constructImageView(image:UIImage) -> Void{
        
        let topPadding:CGFloat = 10.0
        
        let framex = CGRectMake(floor((CGRectGetWidth(self.bounds) - image.size.width)/2),
            topPadding,
            image.size.width,
            image.size.height)
        imageView = UIImageView(frame: framex)
        imageView.image = image
        addSubview(self.imageView)
    }
    
    func constructLabel(text:NSString) -> Void{
        var height:CGFloat = 18.0
        let frame2 = CGRectMake(0,
            CGRectGetMaxY(self.imageView.frame),
            CGRectGetWidth(self.bounds),
            height);
        self.label = UILabel(frame: frame2)
        label.text = text as String
        addSubview(label)
        
    }
}
