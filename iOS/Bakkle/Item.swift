//
//  Item.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/10/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit

class Item: NSObject, Printable {
   
    let title: NSString
    let image: UIImage!
    
    override var description: String {
        return "title: \(title), \n image: \(image)"
    }
    
    
    init(title: NSString?, image: UIImage?) {
        self.title = title ?? ""
        self.image = image
    }
    
}
