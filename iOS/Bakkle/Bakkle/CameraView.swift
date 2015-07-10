//
//  CameraView.swift
//  Bakkle
//
//  Created by Barr, Patrick T on 7/8/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import AVFoundation

class CameraView: UIViewController, UIImagePickerControllerDelegate {
    
    /* SEGUE NAVIGATION */
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var switchCamera: UIButton!
    
    /* AVFOUNDATION */
    @IBOutlet weak var cameraView: UIView!
    var capturePreview: AVCaptureVideoPreviewLayer? = nil
    let captureSession = AVCaptureSession()
    var selectedDevice: AVCaptureDevice?
    
    /* IMAGE CONTAINERS */
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    var imageViews = [UIImageView]()
    var images = [UIImage]()
    
    /* CAPTURE BUTTON */
    @IBOutlet weak var capButtonOutline: UIView!
    @IBOutlet weak var capButtonSpace: UIView!
    @IBOutlet weak var capButton: UIButton!
    
    /* LOWER CONTROLS */
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    /* GALLERY PICKER */
    var galleryPicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // used array literals instead of append because the array should never have to be resized (less space taken up)
        imageViews = [imageView1, imageView2, imageView3, imageView4]
        images = [UIImage.alloc(),UIImage.alloc(),UIImage.alloc(),UIImage.alloc()]
        
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        capButton.addTarget(self, action: "shadeCamButton", forControlEvents: UIControlEvents.TouchDown)
        
        capButton.addTarget(self, action: "shadeCamButton", forControlEvents: UIControlEvents.TouchDragEnter)
        capButton.addTarget(self, action: "resetButtonColor", forControlEvents: UIControlEvents.TouchDragExit)
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        var frontCam = findCameraWithPosition(.Front)
        var backCam = findCameraWithPosition(.Back)
        
        if backCam != nil && frontCam != nil {
            selectedDevice = backCam
            return;
        }
        
        switchCamera.enabled = false
        switchCamera.hidden = true
        
        if backCam != nil {
            selectedDevice = backCam
        } else if frontCam != nil {
            selectedDevice = frontCam
        } else {
            // alert
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for view: UIImageView in imageViews {
            view.layer.cornerRadius = 15.0
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        capButtonOutline.layer.cornerRadius = capButtonOutline.layer.frame.size.width / 2
        capButtonSpace.layer.cornerRadius = capButtonSpace.layer.frame.size.width / 2
        capButton.layer.cornerRadius = capButton.layer.frame.size.width / 2
        
        capButtonOutline.layer.masksToBounds = true
        capButtonSpace.layer.masksToBounds = true
        capButton.layer.masksToBounds = true
        
        galleryButton.setImage(IconImage().gallery(), forState: .Normal)
        closeButton.setImage(IconImage().close(), forState: .Normal)
//        switchCamera.setImage(IconImage().switchCamera(), forState: .Normal)
        
        galleryButton.setTitle("", forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
        switchCamera.setTitle("", forState: .Normal)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    func findCameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices as! [AVCaptureDevice] {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    func displayImagePreview() {
        var error: NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: selectedDevice!, error: &error))
        
        if error != nil {
            println("Error while displaying AVFoundation preview:\n\(error?.localizedDescription)")
        }
        
        capturePreview = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(capturePreview)
        capturePreview?.frame = cameraView.layer.frame
        captureSession.startRunning()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        // do AVFoundation stuff here
    }
    
}