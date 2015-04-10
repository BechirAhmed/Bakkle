//
//  AddItem.swift
//  Bakkle
//
//  Created by Ishank Tandon on 4/7/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import Photos

class AddItem: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let albumName = "Bakkle"
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!

    @IBAction func cancelAdd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func cameraBtn(sender: AnyObject) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
            
        } else{
            //no camera available
            var alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}
