//
//  CameraView.swift
//  Bakkle
//
//  Created by Barr, Patrick T on 7/8/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import AVFoundation
import QuartzCore

class CameraView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /* CONSTANTS */
    // if you change this you need to update storyboard with an extra image view
    // and you need to add extra views to the array of image views
    private static let IMAGE_FREEZE_TIME = 0.5
    private static let FADE_IN_TIME = 0.5
    private static let FLASH_TIME = 0.05
    private static let FOCUS_SQUARE_WIDTH_SCALE: CGFloat = 1.0 / 8.0
    private static let FOCUS_SQUARE_OFFSET: CGFloat = 2.0
    static let MAX_IMAGE_COUNT = 4
    var size: CGSize? = nil
    var stopFocus = false
    
    /* SEGUE NAVIGATION */
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    /* AVFOUNDATION */
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var loadingCameraPreviewLabel: UILabel!
    var capturePreview: AVCaptureVideoPreviewLayer? = nil
    var captureSession: AVCaptureSession?
    var selectedDevice: AVCaptureDeviceInput?
    var stillImageOutput = AVCaptureStillImageOutput()
    @IBOutlet weak var switchCamera: UIButton!
    var error: NSError? = nil
    
    /* IMAGE CONTAINERS */
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    var imageViews = [UIImageView]()
    var imageCount = 0
    var images = [UIImage]()
    
    /* REMOVE IMAGE BUTTONS */
    @IBOutlet weak var removeImage1: UIButton!
    @IBOutlet weak var removeImage2: UIButton!
    @IBOutlet weak var removeImage3: UIButton!
    @IBOutlet weak var removeImage4: UIButton!
    var removeImageButtons = [UIButton]()
    
    /* CAPTURE BUTTON */
    @IBOutlet weak var capButtonOutline: UIView!
    @IBOutlet weak var capButtonSpace: UIView!
    @IBOutlet weak var capButton: UIButton!
    
    /* CAMERA OPTIONS */
    // swap camera is only an IBAction
    @IBOutlet weak var flashSettings: UIButton!
    var flashMode: AVCaptureFlashMode = .Auto
    
    /* GALLERY PICKER */
    var galleryPicker: UIImagePickerController?
    @IBOutlet weak var stillImagePreview: UIImageView!
    @IBOutlet weak var galleryButton: UIButton!
    var stopVideoPreview: Bool = false
    
    /* FADE VIEWS */
    var focusIndicator: UIImageView!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var fadeViewLoadLogo: UIImageView!
    
    /* HELPER VARIABLES */
    var displayingStill = false
    var addItem: AddItem?
    var dragActivated = -1 // -1 = not activated, 0...3 = drag on image n
    var draggedImage: UIButton?
    var imageViewY: CGFloat!
    var imageViewX: [CGFloat!]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        size = CGSize(width: Bakkle.sharedInstance.image_width, height: Bakkle.sharedInstance.image_height)
        stopFocus = false
        
        // consider auto-generating these based on the static CameraView.MAX_IMAGE_COUNT
        imageViews = [imageView1, imageView2, imageView3, imageView4]
        removeImageButtons = [removeImage1, removeImage2, removeImage3, removeImage4]
        
        // ensures that arrays do not occupy more space than needed (capacity == count)
        imageViews.reserveCapacity(imageViews.count)
        removeImageButtons.reserveCapacity(removeImageButtons.count)
        
        images = [UIImage](count:CameraView.MAX_IMAGE_COUNT, repeatedValue:UIImage.alloc())
        
        UIApplication.sharedApplication().statusBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        galleryButton.setImage(IconImage().gallery(), forState: .Normal)
        closeButton.setImage(IconImage().close(), forState: .Normal)
        switchCamera.setImage(IconImage().switchCamera(), forState: .Normal)
        
        galleryButton.setTitle("", forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
        switchCamera.setTitle("", forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
        
        setupAVFoundation()
        loadingCameraPreviewLabel.hidden = false
        
        self.fadeView.alpha = 1.0
        if self.addItem != nil && (self.addItem!.successfulAdd || self.addItem!.confirmHit) {
            self.fadeViewLoadLogo.image = UIImage(named: "logo-white-design-clear.png")!
            var backgroundImage = UIImageView(frame: self.fadeView.frame)
            backgroundImage.image = UIImage(named:"LoginScreen-bkg.png")!
            self.fadeView.insertSubview(backgroundImage, belowSubview: self.fadeViewLoadLogo)
            var successLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width * 0.90, self.fadeViewLoadLogo.frame.size.height))
            successLabel.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, (self.fadeViewLoadLogo.bounds.maxY + UIScreen.mainScreen().bounds.maxY) / 2)
            successLabel.numberOfLines = 0
            successLabel.font = UIFont(name: "Avenir-Black", size: 36)
            successLabel.text = self.addItem!.successfulAdd ? "Your item has been listed!" : "Enjoy browsing while we continue to list your item!"
            successLabel.sizeToFit()
            successLabel.layer.shadowColor = Theme.ColorGreen.CGColor
            successLabel.layer.shadowRadius = 5.0
            successLabel.layer.shadowOpacity = 1.0
            successLabel.textColor = UIColor.whiteColor()
            successLabel.textAlignment = .Center
            self.fadeView.addSubview(successLabel)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        } else if self.addItem != nil {
            self.fadeView.alpha = 0.0
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        imageViewX = [0.0, 0.0, 0.0, 0.0]
        
        var i = 0
        for imageView: UIImageView in imageViews {
            imageView.layer.cornerRadius = 15.0
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 1.0
            imageView.layer.borderColor = UIColor.whiteColor().CGColor
            imageViewY = imageView.convertPoint(imageView.frame.origin, toView: self.view).y
            imageViewX[i++] = imageView.convertPoint(imageView.frame.origin, toView: self.view).x
        }
        
        for removeButton: UIButton in removeImageButtons {
            removeButton.layer.cornerRadius = removeButton.frame.size.width / 2
            removeButton.layer.shadowColor = UIColor.blackColor().CGColor
            removeButton.layer.shadowRadius = 5
            removeButton.layer.shadowOpacity = 1.0
        }
        
        capButtonSpace.layer.cornerRadius = capButtonSpace.frame.size.width / 2
        capButtonOutline.layer.cornerRadius = capButtonOutline.frame.size.width / 2
        capButton.layer.cornerRadius = capButton.frame.size.width / 2
        
        capButtonSpace.layer.masksToBounds = true
        capButtonOutline.layer.masksToBounds = true
        capButton.layer.masksToBounds = true
        
        self.nextButton.enabled = imageCount > 0
        self.nextButton.hidden = imageCount < 1
        
        if !stopVideoPreview {
            displayImagePreview()
        }
        
        buttonEnabledHandler()
        
        flashSettings.userInteractionEnabled = false
        
        
        stopFocus = false
        focusIndicator = UIImageView(frame: CGRectMake(0, 0, CameraView.FOCUS_SQUARE_WIDTH_SCALE * cameraView.frame.size.width, CameraView.FOCUS_SQUARE_WIDTH_SCALE * cameraView.frame.size.width))
        focusIndicator.image = UIImage(named:"FocusIndicator.png")!
        focusIndicator.hidden = true
        focusIndicator.userInteractionEnabled = false
        cameraView.clipsToBounds = true
        cameraView.addSubview(focusIndicator)
        
        if self.addItem == nil {
            UIView.animateWithDuration(CameraView.FADE_IN_TIME, animations: {
                self.fadeView.alpha = 0.0
            })
        }
        
        drawFocusRect()
    }
    
    func setupAVFoundation(){
        if captureSession != nil {
            return
        }
        
        captureSession = AVCaptureSession()
        
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
            // alert is called when previewing, this code is only run before an alert can be shown
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loadingCameraPreviewLabel.hidden = true
        UIApplication.sharedApplication().statusBarHidden = false
        stopFocus = true
        capturePreview?.removeFromSuperlayer()
    }
    
    @IBAction func swapCamera(sender: AnyObject) {
        captureSession!.beginConfiguration()
        
        captureSession!.removeInput(selectedDevice)
        selectedDevice = selectedDevice!.device.isEqual(findCameraWithPosition(.Front)) ? AVCaptureDeviceInput(device: findCameraWithPosition(.Back)!, error: &error) : AVCaptureDeviceInput(device: findCameraWithPosition(.Front)!, error: &error)
        captureSession!.addInput(selectedDevice!)
        
        captureSession!.commitConfiguration()
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
    
    func displayStillImage(image: UIImage) {
        displayingStill = true
        cameraView.contentMode = .ScaleAspectFill
        cameraView.bringSubviewToFront(stillImagePreview)
        stillImagePreview.image = image
    }
    
    func removeStillImage() {
        displayingStill = false
        stillImagePreview.image = nil
        cameraView.sendSubviewToBack(stillImagePreview)
    }
    
    /*
    ** Starts the camera preview. NOT to be confused with displayStillImage
    */
    func displayImagePreview() {
        if self.imageCount >= CameraView.MAX_IMAGE_COUNT {
            // no more images
            return
        }
        
        captureSession!.beginConfiguration()
        
        if findCameraWithPosition(.Front) == nil &&  findCameraWithPosition(.Back) == nil {
            let alertController = UIAlertController(title: "No Camera Available", message:"Sorry, you need to have a camera to list an item.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if !contains(captureSession!.inputs, item: selectedDevice) {
            captureSession!.addInput(selectedDevice!)
            
            if captureSession!.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
                captureSession!.sessionPreset = AVCaptureSessionPreset1280x720
            } else {
                captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
            }
        }
        
        if error != nil {
            println("Error while displaying AVFoundation preview:\n\(error)")
            return
        }
        
        displayingStill = false
        
        capturePreview = AVCaptureVideoPreviewLayer(session: captureSession!)
        capturePreview?.frame = CGRectMake(0, 0, cameraView.layer.frame.width, cameraView.layer.frame.height)
        capturePreview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraView.layer.insertSublayer(capturePreview, below: self.flashView.layer)
        
        if captureSession!.canAddOutput(stillImageOutput) && !contains(captureSession!.outputs, item: stillImageOutput) {
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            captureSession!.addOutput(stillImageOutput)
        }
        
        captureSession!.commitConfiguration()
        
        if !captureSession!.running {
            captureSession!.startRunning()
        }
    }
    
    func contains(array: NSArray, item: AnyObject!) -> Bool {
        for items in array {
            if items.isEqual(item) {
                return true
            }
        }
        return false
    }
    
    // Tap to focus, need to draw square
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if selectedDevice != nil && selectedDevice!.device.focusPointOfInterestSupported {
            var touchPoint = touches.first as! UITouch
            var screenSize = cameraView.bounds.size
            var focusPoint = CGPoint(x: touchPoint.locationInView(cameraView).x / screenSize.width, y: touchPoint.locationInView(cameraView).y / screenSize.height)
            
            if CGRectContainsPoint(self.cameraView.frame, touchPoint.locationInView(nil)) {
                if let device = self.selectedDevice!.device {
                    if(device.lockForConfiguration(nil)) {
                        // focusIndicator removeAllAnimations (this is incase we have the image darken with exposure
                        focusIndicator.hidden = true
                        device.focusPointOfInterest = focusPoint
                        device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                        device.exposurePointOfInterest = focusPoint
                        device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                        device.unlockForConfiguration()
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touchPoint = touches.first as! UITouch
        
        if dragActivated > -1 && dragActivated < imageViews.count {
            
        }
    }
    
    /*
    ** If the touch is ended by the user, insert the view where it is wanted
    */
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touchPoint = touches.first as! UITouch
        
        if dragActivated > -1 && dragActivated < imageViews.count {
            
        }
    }
    
    /*
    ** If the touch is cancelled because of a system event: act as if the user didn't move the view properly
    */
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        var touchPoint = touches.first as! UITouch
        
        if dragActivated > -1 && dragActivated < imageViews.count {
            
        }
    }
    
    func drawFocusRect() {
        // update frame of the indicator IF the device is previewing or displaying a still
        if (selectedDevice!.device.adjustingFocus || selectedDevice!.device.adjustingExposure || selectedDevice!.device.adjustingWhiteBalance) && !displayingStill {
            focusIndicator.removeFromSuperview()
            focusIndicator.frame.origin.x = selectedDevice!.device.focusPointOfInterest.x * cameraView.bounds.size.width - focusIndicator.frame.width / 2.0
            focusIndicator.frame.origin.y = selectedDevice!.device.focusPointOfInterest.y * cameraView.bounds.size.height - focusIndicator.frame.height / 2.0
            cameraView.addSubview(focusIndicator)
            cameraView.bringSubviewToFront(focusIndicator)
            focusIndicator.hidden = false
        } else {
            focusIndicator.hidden = true
        }
        
        if !stopFocus {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((1.0/32.0) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.drawFocusRect()
            }
        }
    }
    
    @IBAction func pressedCaptureButton(sender: AnyObject) {
        // action event: touchDown
        self.capButton.backgroundColor = UIColor.lightGrayColor()
    }
    
    @IBAction func releasedCaptureButton(sender: AnyObject) {
        // action event touchUpOutisde (also called by take photo which is up inside)
        self.capButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        self.releasedCaptureButton(self)
        var videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        if videoConnection != nil {
            self.capButton.enabled = false
            self.nextButton.enabled = false
            var itemIndex = self.imageCount++
            
            var err: NSError?
            
            if self.selectedDevice!.device.hasFlash && self.selectedDevice!.device.lockForConfiguration(&err) {
                self.selectedDevice!.device.flashMode = self.flashMode
                self.selectedDevice!.device.unlockForConfiguration()
            }
            
            if err != nil {
                println(err)
            }
            
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
                if imageDataSampleBuffer != nil {
                    var recentImage = UIImage(data: (AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)))
                    
                    self.flashView.alpha = 0.0
                    self.flashView.hidden = false
                    UIView.animateWithDuration(CameraView.FLASH_TIME, animations: {
                        self.flashView.alpha = 1.0
                    })
                    
                    recentImage!.cropAndResize(self.size!, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
                        var compressedImage = UIImageJPEGRepresentation(resizedImage, CGFloat(Bakkle.sharedInstance.image_quality))
                        self.images[itemIndex] = UIImage(data: compressedImage)!
                        self.displayStillImage(self.images[itemIndex])
                        self.populatePhotos()
                        UIView.animateWithDuration(CameraView.FLASH_TIME * 2, delay: CameraView.FLASH_TIME, options: nil, animations: {
                            self.flashView.alpha = 0
                            }, completion: { Void in
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(CameraView.IMAGE_FREEZE_TIME * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                                        self.buttonEnabledHandler()
                                        if self.imageCount >= CameraView.MAX_IMAGE_COUNT {
                                            if let image = self.imageViews[CameraView.MAX_IMAGE_COUNT - 1].image {
                                                // Incase rapid fire ends up
                                                self.displayStillImage(image)
                                            }
                                        } else {
                                            self.removeStillImage()
                                        }
                                    }
                                })
                    }) // cropAndResize
                    
                    
                } else {
                    NSLog("Error capturing image:\n\(error)")
                }
            })
        } else {
            NSLog("Error in takePhoto: videoConnection was nil")
        }
    }
    
    @IBAction func getFromGallery(sender: AnyObject) {
        // set sourcetype to the proper saved photos in load
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.capButton.enabled = false
        self.nextButton.enabled = false
        self.galleryPicker = UIImagePickerController()
        self.galleryPicker!.delegate = self
        self.galleryPicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(self.galleryPicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var itemIndex = self.imageCount++ // set the index to imageCount then increment the total count by 1
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        image.cropAndResize(self.size!, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
            var compressedImage = UIImageJPEGRepresentation(resizedImage, CGFloat(Bakkle.sharedInstance.image_quality))
            self.images[itemIndex] = UIImage(data: compressedImage)!
            self.displayStillImage(self.images[itemIndex])
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(CameraView.IMAGE_FREEZE_TIME * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.stillImagePreview.image = nil
                self.buttonEnabledHandler()
                if self.imageCount >= CameraView.MAX_IMAGE_COUNT {
                    self.displayStillImage(self.imageViews[CameraView.MAX_IMAGE_COUNT - 1].image!)
                } else {
                    self.displayImagePreview()
                }
            }
            
            self.populatePhotos()
        }) // cropAndResize
        stopVideoPreview = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.buttonEnabledHandler()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func populatePhotos() {
        var imagesNoSpace = [UIImage]()
        for i in 0...(self.images.count - 1) {
            if !(self.images[i].CIImage == nil && self.images[i].CGImage == nil) {
                imagesNoSpace.append(self.images[i])
                
                if i > 0 && (self.imageViews[i - 1].image == nil) {
                    animateSlide(i, toIndex: i-1)
                } else {
                    self.imageViews[i].image = self.images[i]
                }
            }
        }
        
        // This is needed to stop any concurrent modification for the first for loop
        for i in 0...(self.images.count - 1) {
            self.images[i] = i >= imagesNoSpace.count ? UIImage.alloc() : imagesNoSpace[i];
        }
        
        imageCount = imagesNoSpace.count
        
        buttonEnabledHandler()
    }
    
    func animateSlide(fromIndex: Int, toIndex: Int) {
        if fromIndex < self.imageViews.count && toIndex < self.imageViews.count && fromIndex != toIndex {
            var startPoint = self.imageViews[fromIndex].convertPoint(self.imageViews[fromIndex].frame.origin, toView: self.view)
            var slideView = UIImageView(frame: CGRectMake(startPoint.x, startPoint.y, self.imageViews[fromIndex].frame.width, self.imageViews[fromIndex].frame.height))
            slideView.image = self.imageViews[fromIndex].image
            slideView.layer.cornerRadius = 15.0
            slideView.layer.borderColor = UIColor.whiteColor().CGColor
            slideView.layer.borderWidth = 1.0
            slideView.layer.masksToBounds = true
            self.view.addSubview(slideView)
            self.imageViews[fromIndex].image = nil
            buttonEnabledHandler()
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: nil, animations: {
                slideView.frame = CGRectMake(self.imageViewX[toIndex], self.imageViewY, slideView.frame.width, slideView.frame.height)
                }, completion: { Void in
                    self.imageViews[toIndex].image = slideView.image
                    slideView.image = nil
                    slideView.removeFromSuperview()
                    self.buttonEnabledHandler()
            })
        }
    }
    
    func buttonEnabledHandler() {
        self.nextButton.enabled = imageCount > 0
        self.nextButton.hidden = imageCount < 1
        
        var imageCountGreaterThanMaxCount = imageCount >= CameraView.MAX_IMAGE_COUNT
        self.capButton.enabled = !imageCountGreaterThanMaxCount
        self.galleryButton.enabled = !imageCountGreaterThanMaxCount
        self.switchCamera.enabled = !imageCountGreaterThanMaxCount
        self.flashSettings.enabled = !imageCountGreaterThanMaxCount && selectedDevice != nil && selectedDevice!.device.hasFlash
        
        self.capButton.hidden = !self.capButton.enabled
        self.galleryButton.hidden = !self.galleryButton.enabled
        self.switchCamera.hidden = !self.switchCamera.enabled
        self.capButtonOutline.hidden = imageCountGreaterThanMaxCount
        self.capButtonSpace.hidden = imageCountGreaterThanMaxCount
        self.flashSettings.hidden = !self.flashSettings.enabled
        
        for i in 0...(self.imageViews.count - 1) {
            self.removeImageButtons[i].hidden = self.imageViews[i].image == nil
            self.removeImageButtons[i].enabled = self.imageViews[i].image != nil
        }
    }
    
    // rename to long press
    @IBAction func photoHeld(sender: UILongPressGestureRecognizer) {
//        if ((sender.view!) as! UIImageView).image != nil {
//            var newW:CGFloat = sender.view!.frame.width * 1.1
//            var newH:CGFloat = sender.view!.frame.height * 1.1
//            var actualBeginPt = sender.view!.convertPoint(sender.view!.frame.origin, toView: self.view)
//            
//            draggedImage = UIButton(frame: CGRectMake(actualBeginPt.x, actualBeginPt.y, sender.view!.frame.width, sender.view!.frame.height))
//            
//            var x: CGFloat = actualBeginPt.x - (newW - sender.view!.frame.width)
//            var y: CGFloat = actualBeginPt.y - (newH - sender.view!.frame.height)
//            draggedImage!.layer.cornerRadius = 15.0
//            draggedImage!.layer.borderColor = UIColor.whiteColor().CGColor
//            draggedImage!.layer.borderWidth = 1.0
//            draggedImage!.layer.masksToBounds = true
//            draggedImage!.setImage((sender.view! as! UIImageView).image, forState: .Selected)
//            draggedImage!.setImage((sender.view! as! UIImageView).image, forState: .Normal)
//            draggedImage!.hidden = false
//            draggedImage!.enabled = false
//            (sender.view! as! UIImageView).image = nil
//            buttonEnabledHandler()
//            self.view.addSubview(draggedImage!)
//            
////            dragActivated = 
//            
//            UIView.animateWithDuration(1.0, animations: { Void in
//                self.draggedImage!.frame = CGRectMake(x, y, newW, newH)
//                self.draggedImage!.alpha = 0.875
//            })
//        }
    }
    
    func dragImage(point: CGPoint) {
        //        var point: CGPoint = (event.allTouches() as! AnyObject).locationInView(self.view)
        //        sender.frame = CGRectMake(point.x - sender.frame.width / 2, point.y - sender.frame.width / 2, sender.frame.width, sender.frame.height)
        //        UIView.animateWithDuration(0.05, animations: { Void in
        //            sender.frame = CGRectMake(point.x - sender.frame.width / 2, point.y - sender.frame.width / 2, sender.frame.width, sender.frame.height)
        //        })
    }
    
    
    
    func hoverOverPosition(point: CGPoint) {
        
    }
    
    
    
    func successfulRelease(point: CGPoint) {
        
    }
    
    
    
    func failedRelease(point: CGPoint) {
        
    }
    
    @IBAction func photoPreview(sender: UITapGestureRecognizer) {
        var imageViewIndex = sender.view!.tag - 31
        
        let validTags = [1, 10, 20, 21, 30, 31, 32, 33, 34, 40, 41, 42, 43]
        
        if imageViewIndex >= 0 && imageViewIndex < imageViews.count {
            if imageViews[imageViewIndex].image == nil && displayingStill && imageCount < CameraView.MAX_IMAGE_COUNT {
                self.removeStillImage()
//                self.stillImagePreview.image = nil
//                displayImagePreview()
            } else if imageViews[imageViewIndex].image != nil { // safety check
                self.displayStillImage(imageViews[imageViewIndex].image!)
            }
        } else {
            if !contains(validTags, item: sender.view!.tag) {
                NSLog("[CameraView] Error in photoPreview: Unknown Sender\n\(sender)")
            }
        }
    }
    
    @IBAction func removePhoto(sender: UIButton) {
        // the format for tags of remove buttons should be as follows:
        // 321 = removeImage2 where:
        //   3 = row on main UIScreen that the superview is on (3rd row down is images)
        //   2 = second column of items in the row (2nd image)
        //   1 = element in order from left to right (only 1 element, so one identifier)
        // conversion to get the image number is integer division / 10 (get rid of ones)
        // subtract by 31 (row + offset) and the result is the imageView number from left
        // to right in the range of 0-3
        var removeImageIndex = sender.tag / 10 - 31
        
        if removeImageIndex < 0 { // || removeImageIndex >= removeImageButtons.count
            NSLog("[CameraView] Error in removePhoto: Unknown Sender\n\(sender)")
        } else if imageViews[removeImageIndex].image != nil {
            let alertController = UIAlertController(title: "Remove Photo", message:"Are you sure that you want to remove image #\(removeImageIndex + 1)?", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "NO", style: .Default, handler: nil)
            let acceptAction = UIAlertAction(title: "YES", style: .Destructive, handler: { (action: UIAlertAction!) in
                var wasDisplayingRemovedImage = self.displayingStill && self.stillImagePreview.image?.isEqual(self.imageViews[removeImageIndex].image!) != nil
                if wasDisplayingRemovedImage {
                    self.stillImagePreview.image = nil
                }
                
                self.imageViews[removeImageIndex].image = nil
                self.images[removeImageIndex] = UIImage.alloc()
                
                self.imageCount--
                self.populatePhotos()
                
                if wasDisplayingRemovedImage {
                    self.displayImagePreview()
                }
            })
            
            alertController.addAction(acceptAction)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItemSegue" {
            self.populatePhotos() // to be safe
            let destinationVC = segue.destinationViewController as! AddItem
            self.addItem = destinationVC
            destinationVC.itemImages = [UIImage]()
            for image in self.images {
                if !(image.CIImage == nil && image.CGImage == nil) {
                    destinationVC.itemImages?.append(image)
                }
            }
        }
    }
}