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
        return UIImage(named: "new-x.png")!
    }
    
    func chevron() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.ChevronLeft)
    }
    
    func offer() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Dollar)
    }
    
    func money() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Dollar)
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
    
    func edit(color: UIColor) -> UIImage {
        factory.colors = [color]
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
        factory.colors = [UIColor.blackColor()]
        factory.strokeColor = UIColor.blackColor()
        factory.strokeWidth = 0.0
        return factory.createImageForIcon(NIKFontAwesomeIcon.Camera)
    }
    
    /* CAMERA ICONS */
    
    func gallery() -> UIImage {
        setup(NAV_SIZE)
        return factory.createImageForIcon(NIKFontAwesomeIcon.Image)
    }
    
    func switchCamera() -> UIImage {
        return UIImage(named: "switch-camera-outline.png")!
    }
    
    func remove() -> UIImage {
        return UIImage(named: "new-x-black.jpeg")!
    }
    
    func flash_on() -> UIImage {
        return UIImage(named: "camera-flash.png")!
    }
    
    func flash_off() -> UIImage {
        return UIImage(named: "camera-flash-off.png")!
    }
    
    func flash_auto() -> UIImage {
        return UIImage(named: "camera-flash-auto.png")!
    }
}