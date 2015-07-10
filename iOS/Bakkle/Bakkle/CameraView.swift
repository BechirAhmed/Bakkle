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
    var selectedDevice: AVCaptureDeviceInput?
    var error: NSError? = nil
    
    /* IMAGE CONTAINERS */
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    var imageViews = [UIImageView]()
    var images = [UIImage]()
    var imageCount: Int?
    
    /* CAPTURE BUTTON */
    @IBOutlet weak var capButtonOutline: UIView!
    @IBOutlet weak var capButtonSpace: UIView!
    @IBOutlet weak var capButton: UIButton!
    
    /* LOWER CONTROLS */
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    /* GALLERY PICKER */
    var galleryPicker: UIImagePickerController?
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCount = 0
        // used array literals instead of append because the array should never have to be resized (less space taken up)
        imageViews = [imageView1, imageView2, imageView3, imageView4]
        images = [UIImage.alloc(),UIImage.alloc(),UIImage.alloc(),UIImage.alloc()]
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        var frontCam = findCameraWithPosition(.Front)
        var backCam = findCameraWithPosition(.Back)
        
        if backCam != nil && frontCam != nil {
            selectedDevice = AVCaptureDeviceInput(device: backCam!, error: &error)
            return;
        }
        
        switchCamera.enabled = false
        switchCamera.hidden = true
        
        if backCam != nil {
            selectedDevice = AVCaptureDeviceInput(device: backCam!, error: &error)
        } else if frontCam != nil {
            selectedDevice = AVCaptureDeviceInput(device: frontCam!, error: &error)
        } else {
            // alert
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
        
        galleryButton.setImage(IconImage().gallery(), forState: .Normal)
        closeButton.setImage(IconImage().close(), forState: .Normal)
        
        if !switchCamera.hidden {
            switchCamera.setImage(IconImage().switchCamera(), forState: .Normal)
            switchCamera.setTitle("", forState: .Normal)
        }
        
        galleryButton.setTitle("", forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for view: UIImageView in imageViews {
            view.layer.cornerRadius = 15.0
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        capButton.layer.cornerRadius = capButton.layer.frame.size.width / 2
        capButton.layer.masksToBounds = true
        
        capButtonSpace.layer.cornerRadius = capButtonSpace.layer.frame.size.width / 2
        capButtonSpace.layer.masksToBounds = true
        
        capButtonOutline.layer.cornerRadius = capButtonOutline.layer.frame.size.width / 2
        capButtonOutline.layer.masksToBounds = true
        
        displayImagePreview()
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
    
    @IBAction func swapCamera(sender: AnyObject) {
        captureSession.stopRunning()
        captureSession.removeInput(selectedDevice)
        selectedDevice = selectedDevice!.device.isEqual(findCameraWithPosition(.Front)) ? AVCaptureDeviceInput(device: findCameraWithPosition(.Back)!, error: &error) : AVCaptureDeviceInput(device: findCameraWithPosition(.Front)!, error: &error)
        displayImagePreview()
    }
    
    
    func displayImagePreview() {
        
        captureSession.addInput(selectedDevice!)
        
        if error != nil {
            println("Error while displaying AVFoundation preview:\n\(error?.localizedDescription)")
            return
        }
        
        capturePreview = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreview?.frame = cameraView.layer.frame
        capturePreview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(capturePreview)
        
        captureSession.startRunning()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        // do AVFoundation stuff here
        var capturedImage = AVCaptureStillImageOutput()
        capturedImage.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(capturedImage) {
            captureSession.addOutput(capturedImage)
        }
        captureSession.stopRunning()
        var videoConnection = capturedImage.connectionWithMediaType(AVMediaTypeVideo)
        
        if videoConnection != nil {
            capturedImage.captureStillImageAsynchronouslyFromConnection(capturedImage.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (imageDataSampleBuffer, error) -> Void in
                
                var recentImage = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                self.images[self.imageCount!] = UIImage(data: recentImage)!
                
                let scaledImageWidth: CGFloat = 660.0
                var size = CGSize(width: scaledImageWidth, height: scaledImageWidth)
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
                    self.images[self.imageCount!].cropAndResize(size, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
                        var compressedImage = UIImageJPEGRepresentation(resizedImage, AddItem.JPEG_COMPRESSION_CONSTANT)
                        self.images[self.imageCount!] = UIImage(data: compressedImage)!
//                            self.fileSizes = 0
//                            for i in self.scaledImages! {
//                                self.fileSizes += UInt64(i.length)
//                            }
//                            println("Image \(itemIndex! + 1) bit count: \(compressedImage.length) b")
//                            println("Total image size bit count: \(self.fileSizes) b")
                        self.imageCount!++
                        self.populatePhotos()
                    })
                }
            })
        }
    }
    
    func populatePhotos() {
        self.imageViews[self.imageCount!].image = self.images[self.imageCount!]
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.75 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.captureSession.stopRunning()
            self.displayImagePreview()
        }
    }
    
    func reorderPhoto(startIndex: Int, endIndex: Int) {
        
    }
    
    
    @IBAction func removePhoto(sender: AnyObject) {
        // do stuff
        // remember to check which sender brought you here
        
        self.imageCount!--
        self.populatePhotos()
    }
}