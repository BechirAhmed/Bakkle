//
//  ItemData.swift
//  Bakkle
//
//  Created by Barr, Patrick T on 6/5/15.
//  Copyright (c) 2015 Bakkle Inc. All rights reserved.
//

import Foundation
import Photos
import Haneke

class ItemData: AnyObject {
    
    /**
     * Variables to set in FeedView:
     *     view[0, 1, or 2].distLabel.attributedText = distanceString
     *     view[0, 1, or 2].nameLabel.text = title
     *     view[0, 1, or 2].sellerName = sellerName
     *     view[0, 1, or 2].ratingView = rating
     */
    
    /* Item Specific Data */
    let item: NSObject
    let imgURLs: NSArray
    let title: String
    let price: String
    let distanceString: NSMutableAttributedString
    let method: String
    
    /* Seller Data */
    private static let DEFAULT_RATING: Float32 = 3.5
    let sellerProfile: NSDictionary
    let sellerName: String
    let rating: Float32
    let facebookID: String
    let facebookProfileImgString: String
    
    init(feedItemNumber: Int) {
        self.item = Bakkle.sharedInstance.feedItems[feedItemNumber]
        
        // Keys can be found in /www/bakkle/account/models.py
        self.imgURLs = item.valueForKey("image_urls") as! NSArray
        self.title = item.valueForKey("title") as! String
        self.price = item.valueForKey("price") as! String
        self.distanceString = ItemData.distanceStringCalc(item.valueForKey("location") as! String)
        self.method = item.valueForKey("method") as! String
        
        self.sellerProfile = item.valueForKey("seller") as! NSDictionary
        self.sellerName = "" //sellerProfile.valueForKey("display_name") as! String
        let localRating = item.valueForKey("seller_rating") as! String
        self.rating = localRating.isEmpty ? ItemData.DEFAULT_RATING : (localRating as NSString).floatValue
        self.facebookID = sellerProfile.valueForKey("facebook_id") as! String
        self.facebookProfileImgString = "https://graph.facebook.com/\(facebookID)/picture?width=142&height=142"
    }
    
    private init(item: NSObject, imgURLs: NSArray, title: String, price: String, distanceString: NSMutableAttributedString, method: String, sellerProfile: NSDictionary, sellerName: String, rating: Float32, facebookID: String, facebookProfileImgString: String) {
        self.item = item
        self.imgURLs = imgURLs
        self.title = title
        self.price = price
        self.distanceString = distanceString
        self.method = method
        self.sellerProfile = sellerProfile
        self.sellerName = sellerName
        self.rating = rating
        self.facebookID = facebookID
        self.facebookProfileImgString = facebookProfileImgString
    }
    
    /**
     * I'm not quite sure what Ishank was doing when he wrote something like this
     * in the updateView() method of FeedView.swift; if I were to guess, it would
     * be setting a value to the distance field of FeedView
     */
    static func distanceStringCalc(location: String) -> NSMutableAttributedString {
        let start: CLLocation = CLLocation(locationString: location)
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "icon-marker75.png")
        let attachmentString : NSAttributedString = NSAttributedString(attachment: attachment)
        var distStr: NSMutableAttributedString
        
        if let distance = Bakkle.sharedInstance.distanceTo(start) {
            distStr = NSMutableAttributedString(string:  " " + String(stringInterpolationSegment: Int(distance)) + " miles")
        } else {
            distStr = NSMutableAttributedString(string: " ERROR: DISTANCE UNKNOWN")
        }
        
        distStr.insertAttributedString(attachmentString, atIndex: 0)
        return distStr
    }
    
//    func copy() -> ItemData {
//        var copyClass: ItemData = init(item: self.item, imgURLs: self.imgURLs, title: self.title, price: self.price, distanceString: self.distanceString, method: self.method, sellerProfile: self.sellerProfile, sellerName: self.SellerName, rating: self.rating, facebookID: self.facebookID, facebookProfileImgString: self.facebookProfileImgString)
//        return copyClass
//    }
    
    /**
     * The following functions return the value of their respective constants
     */
    
    func getItem() -> NSObject {
        return self.item
    }
    
    func getImgURLs() -> NSArray {
        return self.imgURLs
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getPrice() -> String {
        return self.price
    }
    
    func getDistanceString() -> NSMutableAttributedString {
        return self.distanceString
    }
    
    func getMethod() -> String {
        return self.method
    }
    
    func getSellerProfile() -> NSDictionary {
        return self.sellerProfile
    }
    
    func getSellerName() -> String {
        return self.sellerName
    }
    
    func getSellerRating() -> Float32 {
        return self.rating
    }
    
    func getSellerFacebookID() -> String {
        return self.facebookID
    }
    
    func getFacebookProfileImgString() -> String {
        return self.facebookProfileImgString
    }
}