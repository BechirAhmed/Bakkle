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
    private static let IMAGE_FREEZE_TIME = 0.25
    private static let FADE_IN_TIME = 0.5
    private static let FLASH_TIME = 0.05
    static let MAX_IMAGE_COUNT = 4
    static let JPEG_COMPRESSION_FACTOR: CGFloat = 0.3
    static let scaledImageWidth: CGFloat = 660.0
    var size: CGSize? = nil
    
    /* SEGUE NAVIGATION */
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    /* AVFOUNDATION */
    @IBOutlet weak var cameraView: UIView!
    var capturePreview: AVCaptureVideoPreviewLayer? = nil
    var captureSession = AVCaptureSession()
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
//    @IBOutlet weak var flashSettings: ??
    var flashMode: AVCaptureFlashMode = .Auto
    
    /* GALLERY PICKER */
    var galleryPicker: UIImagePickerController?
    @IBOutlet weak var stillImagePreview: UIImageView!
    @IBOutlet weak var galleryButton: UIButton!
    var stopVideoPreview: Bool = false
    
    /* FADE VIEWS */
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var fadeViewLoadLogo: UIImageView!
    
    /* HELPER VARIABLES */
    var displayingStill = false
    var addItem: AddItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        size = CGSize(width: CameraView.scaledImageWidth, height: CameraView.scaledImageWidth)
        
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
        
        self.fadeView.alpha = 1.0
        if self.addItem != nil && self.addItem!.successfulAdd {
            self.fadeViewLoadLogo.image = UIImage(named: "logo-white-design-clear.png")!
            var backgroundImage = UIImageView(frame: self.fadeView.frame)
            backgroundImage.image = UIImage(named:"LoginScreen-bkg.png")!
            self.fadeView.insertSubview(backgroundImage, belowSubview: self.fadeViewLoadLogo)
            var successLabel = UILabel(frame: CGRectMake(0, 0, self.fadeViewLoadLogo.frame.size.width, self.fadeViewLoadLogo.frame.size.height))
            successLabel.center = CGPointMake(self.fadeView.bounds.size.width / 2, (self.fadeViewLoadLogo.bounds.maxY + self.fadeView.bounds.maxY)/2)
            successLabel.numberOfLines = 0
            successLabel.font = UIFont(name: "Avenir-Black", size: 36)
            successLabel.text = "Your item has been listed!"
            successLabel.layer.shadowColor = Theme.ColorGreen.CGColor
            successLabel.layer.shadowRadius = 5.0
            successLabel.layer.shadowOpacity = 1.0
            successLabel.textColor = UIColor.whiteColor()
            successLabel.textAlignment = .Center
            self.fadeView.addSubview(successLabel)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        for imageView: UIImageView in imageViews {
            imageView.layer.cornerRadius = 15.0
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 1.0
            imageView.layer.borderColor = UIColor.whiteColor().CGColor
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
        
        if self.addItem == nil || !self.addItem!.successfulAdd {
            UIView.animateWithDuration(CameraView.FADE_IN_TIME, animations: {
                self.fadeView.alpha = 0.0
            })
        }
    }
    
    func setupAVFoundation(){
        captureSession = AVCaptureSession()
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
            // alert is called when previewing, this code is only run before an alert can be shown
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
        capturePreview?.removeFromSuperlayer()
    }
    
    @IBAction func swapCamera(sender: AnyObject) {
        captureSession.stopRunning()
        captureSession.removeInput(selectedDevice)
        selectedDevice = selectedDevice!.device.isEqual(findCameraWithPosition(.Front)) ? AVCaptureDeviceInput(device: findCameraWithPosition(.Back)!, error: &error) : AVCaptureDeviceInput(device: findCameraWithPosition(.Front)!, error: &error)
        displayImagePreview()
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
        // make AVFoundation display a still image (for gallery and image preview)
//        captureSession.removeInput(selectedDevice)
//        capturePreview?.removeFromSuperlayer()
        cameraView.contentMode = .ScaleAspectFill
        cameraView.bringSubviewToFront(stillImagePreview)
        stillImagePreview.image = image
    }
    
    func removeStillImage() {
        displayingStill = false
        stillImagePreview.image = nil
        cameraView.sendSubviewToBack(stillImagePreview)
    }
    
    func displayImagePreview() {
        if self.imageCount >= CameraView.MAX_IMAGE_COUNT {
            // no more images
            return
        }
        
        captureSession.stopRunning()
        
        if findCameraWithPosition(.Front) == nil &&  findCameraWithPosition(.Back) == nil {
            let alertController = UIAlertController(title: "No Camera Available", message:"Sorry, you need to have a camera to list an item.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if !contains(captureSession.inputs, item: selectedDevice) {
            captureSession.addInput(selectedDevice!)
        }
        
        if error != nil {
            println("Error while displaying AVFoundation preview:\n\(error)")
            return
        }
        
        displayingStill = false
        
        capturePreview = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreview?.frame = CGRectMake(0, 0, cameraView.layer.frame.width, cameraView.layer.frame.height)
        capturePreview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraView.layer.insertSublayer(capturePreview, below: self.flashView.layer)
        captureSession.startRunning()
        
        if captureSession.canAddOutput(stillImageOutput) && !contains(captureSession.outputs, item: stillImageOutput) {
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            captureSession.addOutput(stillImageOutput)
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
        var touchPoint = touches.first as! UITouch
        var screenSize = cameraView.bounds.size
        var focusPoint = CGPoint(x: touchPoint.locationInView(cameraView).y / screenSize.height, y: touchPoint.locationInView(cameraView).x / screenSize.width)
        
        if CGRectContainsPoint(self.cameraView.frame, touchPoint.locationInView(nil)) {
            if let device = self.selectedDevice!.device {
                if(device.lockForConfiguration(nil)) {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                    device.unlockForConfiguration()
                }
            }
        }
    }
    
    func drawFocusRect() {
        
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
                    
                    self.displayStillImage(recentImage!)
//                    self.displayStillImage(recentImage!)
//                    self.capturePreview?.removeFromSuperlayer()
                    
                    UIView.animateWithDuration(CameraView.FLASH_TIME * 2, delay: CameraView.FLASH_TIME, options: nil, animations: {
                        self.flashView.alpha = 0
                    }, completion: nil)
                    
                    recentImage!.cropAndResize(self.size!, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
                        var compressedImage = UIImageJPEGRepresentation(resizedImage, CameraView.JPEG_COMPRESSION_FACTOR)
                        self.images[itemIndex] = UIImage(data: compressedImage)!
                        self.populatePhotos()
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(CameraView.IMAGE_FREEZE_TIME * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                            self.buttonEnabledHandler()
                            if self.imageCount >= CameraView.MAX_IMAGE_COUNT {
                                if let image = self.imageViews[CameraView.MAX_IMAGE_COUNT - 1].image {
                                    // Incase rapid fire ends up
                                    self.displayStillImage(image)
                                }
                            } else {
                                self.removeStillImage()
                                //                                self.cameraView.layer.addSublayer(self.capturePreview)
                            }
                        }
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
//        captureSession.stopRunning()
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
            var compressedImage = UIImageJPEGRepresentation(resizedImage, CameraView.JPEG_COMPRESSION_FACTOR)
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
//        captureSession.startRunning()
        self.buttonEnabledHandler()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func populatePhotos() {
        var imagesNoSpace = [UIImage]()
        for i in 0...(self.images.count - 1) {
            if !(self.images[i].CIImage == nil && self.images[i].CGImage == nil) {
                imagesNoSpace.append(self.images[i])
            }
        }
        for i in 0...(self.images.count - 1) {
            if i >= imagesNoSpace.count {
                self.images[i] = UIImage.alloc()
                self.imageViews[i].image = nil
            } else {
                self.images[i] = imagesNoSpace[i]
                self.imageViews[i].image = imagesNoSpace[i]
            }
        }
        
        imageCount = imagesNoSpace.count
        
        buttonEnabledHandler()
    }
    
    func buttonEnabledHandler() {
        self.nextButton.enabled = imageCount > 0
        self.nextButton.hidden = imageCount < 1
        
        var imageCountGreaterThanMaxCount = imageCount >= CameraView.MAX_IMAGE_COUNT
        self.capButton.enabled = !imageCountGreaterThanMaxCount
        self.galleryButton.enabled = !imageCountGreaterThanMaxCount
        self.switchCamera.enabled = !imageCountGreaterThanMaxCount
        
        self.capButton.hidden = imageCountGreaterThanMaxCount
        self.galleryButton.hidden = imageCountGreaterThanMaxCount
        self.switchCamera.hidden = imageCountGreaterThanMaxCount
        self.capButtonOutline.hidden = imageCountGreaterThanMaxCount
        self.capButtonSpace.hidden = imageCountGreaterThanMaxCount
        
        for i in 0...(self.imageViews.count - 1) {
            self.removeImageButtons[i].hidden = self.imageViews[i].image == nil
            self.removeImageButtons[i].enabled = self.imageViews[i].image != nil
        }
    }
    
    // rename to long press
    @IBAction func photoHeld(sender: AnyObject) {
        //switch(sender. )
        //case :
        //case :
        //case :
        //case :
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