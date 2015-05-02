//
//  ItemTile.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 5/1/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class ItemTile: UIImageView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.greenColor()
//        MKNumberBadgeView *badge=[[MKNumberBadgeView alloc]initWithFrame:CGRectMake(92, 0, 40, 40)];
//        badge.value=6;
//        [self.navigationController.navigationBar addSubview:badge];
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
