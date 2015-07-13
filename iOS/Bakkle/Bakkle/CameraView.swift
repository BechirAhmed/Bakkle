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
    /* Constants */
    // if you change this you need to update storyboard with an extra image view
    // and you need to add extra views to the array of image views
    static let MAX_IMAGE_COUNT = 4
    static let JPEG_COMPRESSION_FACTOR: CGFloat = 0.3
    
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
    
    /* CAPTURE BUTTON */
    @IBOutlet weak var capButtonOutline: UIView!
    @IBOutlet weak var capButtonSpace: UIView!
    @IBOutlet weak var capButton: UIButton!
    
    
    /* GALLERY PICKER */
    var galleryPicker: UIImagePickerController?
    @IBOutlet weak var stillImagePreview: UIImageView!
    @IBOutlet weak var galleryButton: UIButton!
    var stopVideoPreview: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ensures that arrays do not occupy more space than needed (capacity == count)
        imageViews = [imageView1, imageView2, imageView3, imageView4]
        images = [UIImage](count:CameraView.MAX_IMAGE_COUNT, repeatedValue:UIImage.alloc())
        
        UIApplication.sharedApplication().statusBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        galleryButton.setImage(IconImage().gallery(), forState: .Normal)
        closeButton.setImage(IconImage().close(), forState: .Normal)
        switchCamera.setImage(IconImage().switchCamera(), forState: .Normal)
        
        galleryButton.setTitle("", forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
        switchCamera.setTitle("", forState: .Normal)
        
//        for view in imageViews {
//            var gestureRecognizer: UIGestureRecognizer = UIGestureRecognizer.
//            var imageButton: UIGestureRecognizer = UITapGestureRecognizer.addTarget(self, action:"")
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        setupAVFoundation()
        
        for view: UIImageView in imageViews {
            view.layer.cornerRadius = 15.0
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.whiteColor().CGColor
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
            // alert
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
        // make AVFoundation display a still image (for gallery and image preview)
        captureSession.removeInput(selectedDevice)
        capturePreview?.removeFromSuperlayer()
        
        stillImagePreview.image = image
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.75 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.stillImagePreview.image = nil
            self.displayImagePreview()
            self.buttonEnabledHandler()
        }
    }
    
    func displayImagePreview() {
        if self.imageCount >= CameraView.MAX_IMAGE_COUNT {
            // no more images
        }
        
        if !contains(captureSession.inputs, item: selectedDevice) {
            captureSession.addInput(selectedDevice!)
        }
        
        if error != nil {
            println("Error while displaying AVFoundation preview:\n\(error)")
            return
        }
        
        capturePreview = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreview?.frame = cameraView.layer.frame
        capturePreview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(capturePreview)
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
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
                if imageDataSampleBuffer != nil {
                    var recentImage = UIImage(data: (AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)))
                    let scaledImageWidth: CGFloat = 660.0
                    var size = CGSize(width: scaledImageWidth, height: scaledImageWidth)
                    
                    // this makes it appear as if there was a "flash" after you press capture on the image, and it ensures that the flash will unfreeze
                    // after the image has been displayed in
                    self.captureSession.stopRunning()
                    
                    recentImage!.cropAndResize(size, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
                        var compressedImage = UIImageJPEGRepresentation(resizedImage, CameraView.JPEG_COMPRESSION_FACTOR)
                        self.images[itemIndex] = UIImage(data: compressedImage)!
                        self.populatePhotos()
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.75 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                            self.captureSession.startRunning()
                            self.buttonEnabledHandler()
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
        captureSession.stopRunning()
        self.capButton.enabled = false
        self.nextButton.enabled = false
        self.galleryPicker = UIImagePickerController()
        self.galleryPicker!.delegate = self
        self.galleryPicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(self.galleryPicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let scaledImageWidth: CGFloat = 660.0 // make this a constant
        var size = CGSize(width: scaledImageWidth, height: scaledImageWidth) // make this a global constant
        var itemIndex = self.imageCount++ // set the index to imageCount then increment the total count by 1
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        image.cropAndResize(size, completionHandler: { (resizedImage:UIImage, data:NSData) -> () in
        var compressedImage = UIImageJPEGRepresentation(resizedImage, CameraView.JPEG_COMPRESSION_FACTOR)
            self.images[itemIndex] = UIImage(data: compressedImage)!
            self.displayStillImage(self.images[itemIndex])
            self.populatePhotos()
        }) // cropAndResize
        stopVideoPreview = true
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        captureSession.startRunning()
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
    }
    
    // rename to long press
    @IBAction func photoHeld(sender: AnyObject) {
        
    }
    
    @IBAction func photoPreview(sender: AnyObject) {
        
    }
    
    @IBAction func resetToCameraView(sender: AnyObject) {
        
    }
    
    func reorderPhoto(startIndex: Int, endIndex: Int) {
        
    }
    
    @IBAction func removePhoto(sender: AnyObject) {
        // do stuff
        // remember to check which sender to identify which image
        
        self.imageCount--
        self.populatePhotos()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItemSegue" {
            let destinationVC = segue.destinationViewController as! AddItem
            for image in self.images {
                destinationVC.itemImages?.append(image)
//                destinationVC.scaledImages?.append(UIImageJPEGRepresentation(image, 1.0))
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}