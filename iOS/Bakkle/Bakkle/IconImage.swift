//
//  IconImage.swift
//  Bakkle
//
//  Created by Carroll, Joseph B on 6/8/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation
import FontAwesomeIconFactory

class IconImage {
    
    let factory = NIKFontAwesomeIconFactory.textlessButtonIconFactory()
    let NAV_SIZE: CGFloat = 30.0
    let MENU_SIZE: CGFloat = 24.0
    let FEED_SIZE: CGFloat = 20.0
    
    
    func setup(size: CGFloat){
        factory.size = size
        factory.colors = [UIColor.whiteColor()]
        factory.strokeColor = UIColor.whiteColor()
        factory.strokeWidth = 0.0
    }
    
    /* NAVIGATION ICONS */
    
    func menu() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Bars)
    }
    
    func close() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Close)
    }
    
    func chevron() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.ChevronLeft)
    }
    
    func gallery() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Image)
    }
    
    /* SWIPE MENU ICONS */
    
    func home() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Home)
    }
    
    func edit() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Edit)
    }
    
    func cart() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.ShoppingCart)
    }
    
    func down() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.ArrowDown)
    }
    
    func filter() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Filter)
    }
    
    func settings() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Cog)
    }
    
    /* FEED VIEW ICONS */
    
    func tags() -> UIImage {
        setup(FEED_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Tags)
    }
    
    func pin() -> UIImage {
        setup(FEED_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.MapMarker)
    }
    
    func car() -> UIImage {
        setup(FEED_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Automobile)
    }
}