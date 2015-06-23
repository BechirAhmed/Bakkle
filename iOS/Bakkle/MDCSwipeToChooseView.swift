//
//  MDCSwipeToChooseView.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/10/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class MDCSwipeToChooseView: MDCSwipeToChooseView {

    let chooseItemViewLabel: CGFloat = 42.0
    var item: Item!
    var infoView: UIView!
    var nameLabel: UILabel!
    
    init(frame: CGRect, item: Item, options: MDCSwipeToChooseViewOptions) {
        super.init(frame: frame, options: options)
        self.item = item
        
        self.imageView.image = self.item.image!
        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        UIViewAutoresizing.FlexibleBottomMargin
        
        self.imageView.autoresizingMask = self.autoresizingMask
        constructInfoView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(code: aDecoder)
    }
    
    func constructInfoView() {
        var bottomHeight:CGFloat = 60.0
        var bottomFrame:CGRect = CGRectMake(0,
            CGRectGetHeight(self.bounds) - bottomHeight,
            CGRectGetWidth(self.bounds),
            bottomHeight);
        self.infoView = UIView(frame:bottomFrame)
        self.infoView.backgroundColor = UIColor.whiteColor()
        self.infoView.clipstoBounds = true
        self.infoView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
    }

}
