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
    let CHAT_SIZE: CGFloat = 17.0
    
    
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
        return UIImage(named: "x-image.png")!
    }
    
    func chevron() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.ChevronLeft)
    }
    
    func gallery() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Image)
    }
    
    func check() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Check)
    }
    
    /* SWIPE MENU ICONS */
    
    func home() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Home)
    }
    
    func edit(size: CGFloat) -> UIImage {
        setup(size)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Edit)
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
    
    func contact() -> UIImage {
        setup(MENU_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Envelope)
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
    
    /* CHAT ICONS */
    
    func camera() -> UIImage {
        setup(CHAT_SIZE)
        factory.colors = [UIColor.redColor()]
        factory.strokeColor = UIColor.redColor()
        factory.strokeWidth = 0.0
        return factory.createImageForIcon(NIKFontAwesomeIcon.Camera)
    }
}