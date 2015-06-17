//
//  Image+Resize.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 5/8/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation

extension UIImage {
    public func resize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            var newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.6)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData)
            })
        })
    }
    public func cropToSquare(completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
            let contextImage: UIImage = UIImage(CGImage: self.CGImage)!
            
            // Get the size of the contextImage
            let contextSize: CGSize = contextImage.size
            
            let posX: CGFloat
            let posY: CGFloat
            let width: CGFloat
            let height: CGFloat
            
            // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
            if contextSize.width > contextSize.height {
                posX = ((contextSize.width - contextSize.height) / 2)
                posY = 0
                width = contextSize.height
                height = contextSize.height
            } else {
                posX = 0
                posY = ((contextSize.height - contextSize.width) / 2)
                width = contextSize.width
                height = contextSize.width
            }
            
            let rect: CGRect = CGRectMake(posX, posY, width, height)
            
            // Create bitmap image from context using the rect
            let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
            
            // Create a new image based on the imageRef and rotate back to the original orientation
            let image: UIImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)!
            
            let imageData = UIImageJPEGRepresentation(image, 0.7)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: image, data:imageData)
            })
        })
    }
    
    public func cropAndResize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            self.cropToSquare({(croppedImg:UIImage,cropBob:NSData) -> () in
                croppedImg.resize(size, completionHandler: {(scaledImg:UIImage,scaleBob:NSData) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(resizedImage: scaledImg, data:scaleBob)
                    })
                })
            })
        })
    }
    
}