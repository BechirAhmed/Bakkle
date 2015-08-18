//
//  CameraView.swift
//  Bakkle
//
//  Created by Barr, Patrick T on 7/8/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import AVFoundation
import QuartzCore

class CameraView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureFileOutputRecordingDelegate {
    
    /* CONSTANTS */
    // if you change MAX_IMAGE_COUNT you need to update storyboard with an extra image view
    // and you need to add extra views to the array of image views
    private static let IMAGE_FREEZE_TIME = 0.5
    private static let FADE_IN_TIME = 0.5
    private static let IMAGE_SLIDE_ANIMATION_TIME = 0.2
    private static let FLASH_TIME = 0.05
    private static let FOCUS_SQUARE_WIDTH_SCALE: CGFloat = 1.0 / 8.0
    private static let FOCUS_SQUARE_OFFSET: CGFloat = 2.0
    static let MAX_IMAGE_COUNT = 4
    static let MAX_VIDEO_COUNT = 1
    var size: CGSize? = nil
    
    /* ORIGIN IDENTIFIERS */
    var isEditting: Bool = false
    var item: NSDictionary!
    
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
    var videoOutput = AVCaptureMovieFileOutput()
    var audioInput: AVCaptureDeviceInput?
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
    var videos = [NSURL]()
    var videoImages = [UIImage]()
    
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
    
    /* FADE VIEWS */
    var focusIndicator: UIImageView!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var fadeViewLoadLogo: UIImageView!
    @IBOutlet weak var listedLabel: UILabel!
    @IBOutlet weak var willBeListedLabel: UILabel!
    
    /* HELPER VARIABLES */
    var displayingStill = false
    var addItem: AddItem?
    var cameraCount: Int = 0
    var dragActivated = -1 // -1 = not activated, 0...3 = drag on image n
    var draggedImage: UIImageView?
    var imageViewY: CGFloat!
    var imageViewX: [CGFloat]!
    var lockRelease: [Bool]!
    var isVideo: [Bool]!
    var stopFocus = false
    var animating: Int = 0 // image rearrangement
    var notPopulated = false // true if is editing and has already populated
    private var recordingDidChange = 0
    
    // Initialize all variables
    override func viewDidLoad() {
        super.viewDidLoad()
        
        size = CGSize(width: Bakkle.sharedInstance.image_width, height: Bakkle.sharedInstance.image_height)
        stopFocus = false
        
        // consider auto-generating views based on the static CameraView.MAX_IMAGE_COUNT
        imageViews = [imageView1, imageView2, imageView3, imageView4]
        removeImageButtons = [removeImage1, removeImage2, removeImage3, removeImage4]
        
        // ensures that arrays do not occupy more space than needed (capacity == count)
        imageViews.reserveCapacity(imageViews.count)
        removeImageButtons.reserveCapacity(removeImageButtons.count)
        
        images = [UIImage](count:CameraView.MAX_IMAGE_COUNT, repeatedValue:UIImage.alloc())
        isVideo = [Bool](count:CameraView.MAX_IMAGE_COUNT, repeatedValue:false)
        videos = [NSURL](count:CameraView.MAX_VIDEO_COUNT, repeatedValue:NSURL())
        videoImages = [UIImage](count:CameraView.MAX_VIDEO_COUNT, repeatedValue:UIImage.alloc())
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        galleryButton.setImage(IconImage().gallery(), forState: .Normal)
        closeButton.setImage(IconImage().close(), forState: .Normal)
        switchCamera.setImage(IconImage().switchCamera(), forState: .Normal)
        
        galleryButton.setTitle("", forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
        switchCamera.setTitle("", forState: .Normal)
    }
    
    // Check if the view is new, came back from add item for editing, came back during upload, or came back after successful upload
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        
        setupAVFoundation()
        loadingCameraPreviewLabel.hidden = false
        
        // FadeView is used to hide all the corner rounding on the views, as well as waiting for AVFoundation to setup
        self.fadeView.alpha = 1.0
        if self.addItem != nil && (self.addItem!.successfulAdd || self.addItem!.confirmHit) {
            // If the view became active after the confirm button was hit, then display the Bakkle Item added slash
            self.fadeViewLoadLogo.image = UIImage(named: "logo-white-design-clear.png")!
            var backgroundImage = UIImageView(frame: self.fadeView.frame)
            backgroundImage.image = UIImage(named:"LoginScreen-bkg.png")!
            self.fadeView.insertSubview(backgroundImage, belowSubview: self.fadeViewLoadLogo)
            
            // Text is set in storyboard to get a feel of orientation
            var successLabel = self.addItem!.successfulAdd ? listedLabel : willBeListedLabel
            if isEditting {
                // set the text of the label accordingly with uploading an item and while it is being uploaded
                successLabel.text = self.addItem!.successfulAdd ? "Your changes were submitted successfully!" : "Don't worry, we're still updating your changes!"
            }
            successLabel.layer.shadowColor = Theme.ColorGreen.CGColor
            successLabel.layer.shadowRadius = 5.0
            successLabel.layer.shadowOpacity = 1.0
            successLabel.hidden = false
            
            if self.addItem!.successfulAdd {
                self.removeVideos()
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        } else if self.addItem != nil {
            self.fadeView.alpha = 0.0
        } else if isEditting && !self.notPopulated {
            let imageUrls = item.valueForKey("image_urls") as! Array<String>
            self.videoCount = 0
            self.notPopulated = true
            
            for index in 0...imageUrls.count-1 {
                var imageURL: NSURL = NSURL(string: imageUrls[index])!
                
                if imageURL.pathExtension != "mp4" {
                    var imageData: NSData = NSData(contentsOfURL: imageURL)!
                    images[index] = UIImage(data: imageData)!
                } else {
                    videos[self.videoCount] = imageURL
                    videoImages[self.videoCount++] = Bakkle.sharedInstance.previewImageForLocalVideo(imageURL)!
                    self.isVideo[images.count - self.videoCount] = true
                }
            }
        }
    }
    
    // Make any aesthetic UI changes (corner rounding, etc) and setup AVFoundation
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        imageViewX = [CGFloat](count: self.imageViews.count, repeatedValue: 0.0)
        lockRelease = [Bool](count: self.imageViews.count, repeatedValue: false)
        
        var i = 0
        for imageView: UIImageView in imageViews {
            imageViewY = imageView.convertPoint(imageView.frame.origin, toView: self.view).y
            imageViewX[i++] = imageView.convertPoint(imageView.frame.origin, toView: self.view).x
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
        
        displayImagePreview()
        
        videoOutput.addObserver(self, forKeyPath: "recording", options: .New, context: &recordingDidChange)
        
        buttonEnabledHandler()
        
        flashSettings.userInteractionEnabled = false
        
        stopFocus = false
        focusIndicator = UIImageView(frame: CGRectMake(0, 0, CameraView.FOCUS_SQUARE_WIDTH_SCALE * cameraView.frame.size.width, CameraView.FOCUS_SQUARE_WIDTH_SCALE * cameraView.frame.size.width))
        focusIndicator.image = UIImage(named:"FocusIndicator.png")!
        focusIndicator.hidden = true
        focusIndicator.userInteractionEnabled = false
        cameraView.clipsToBounds = true
        cameraView.addSubview(focusIndicator)
        
        // If the CameraView came into view with images, show them
        populatePhotos()
        
        // Any code that doesn't need the fade view active after this point
        
        if self.addItem == nil {
            UIView.animateWithDuration(CameraView.FADE_IN_TIME, animations: {
                self.fadeView.alpha = 0.0
            })
        }
        
        // Call function that updates 32 times a second to draw a focus indicator
        drawFocusRect()
    }
    
    // Specific observer to update the UI when recording either begins or finishes
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &recordingDidChange {
            buttonEnabledHandler()
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // Does any initial AVFoundation setup, should only need to be called when view appears
    func setupAVFoundation(){
        if captureSession != nil {
            return
        }
        
        captureSession = AVCaptureSession()
        
        // Audio Input
        var audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        var err: NSError?
        self.audioInput = AVCaptureDeviceInput(device: audioDevice, error: &err)
        if audioInput != nil {
            captureSession!.addInput(self.audioInput)
        }
        
        // Video Input
        var frontCam = findCameraWithPosition(.Front)
        var backCam = findCameraWithPosition(.Back)
        
        if backCam != nil && frontCam != nil {
            selectedDevice = AVCaptureDeviceInput(device: backCam!, error: &error)
            cameraCount = 2
            return;
        }
        
        switchCamera.enabled = false
        switchCamera.hidden = true
        
        if backCam != nil {
            selectedDevice = AVCaptureDeviceInput(device: backCam!, error: &error)
            cameraCount = 1
        } else if frontCam != nil {
            selectedDevice = AVCaptureDeviceInput(device: frontCam!, error: &error)
            cameraCount = 1
        } else {
            // alert is called when previewing, this code is only run before an alert can be shown
        }
    }
    
    // Cancel button was pressed, remove any unwanted video files
    @IBAction func cancel(sender: AnyObject) {
        self.removeVideos()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Iterates through all the types of files saved for movies and removes them
    func removeVideos() {
        for i in 0...videoCount {
            self.removeVideos(i)
        }
    }
    
    // Removes the specified video
    func removeVideos(index: Int) {
        var err: NSError?
        if NSFileManager.defaultManager().fileExistsAtPath("\(NSTemporaryDirectory())video\(index).mov") {
            NSFileManager.defaultManager().removeItemAtPath("\(NSTemporaryDirectory())video\(index).mov", error: &err)
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath("\(NSTemporaryDirectory())video\(index).mp4") {
            NSFileManager.defaultManager().removeItemAtPath("\(NSTemporaryDirectory())video\(index).mp4", error: &err)
        }
    }
    
    // When a segue out happend, remove anything that we can to save space and cpu
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loadingCameraPreviewLabel.hidden = true
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        stopFocus = true
        capturePreview?.removeFromSuperlayer()
        focusIndicator.removeFromSuperview()
        videoOutput.removeObserver(self, forKeyPath: "recording", context: &recordingDidChange)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.listedLabel.hidden = true
        self.willBeListedLabel.hidden = true
    }
    
    // Change camera position, and animate with a "flip"
    @IBAction func swapCamera(sender: AnyObject) {
        // Remember to begin and commit configuration so all changes happen at once
        captureSession!.beginConfiguration()
        
        captureSession!.removeInput(selectedDevice)
        selectedDevice = selectedDevice!.device.isEqual(findCameraWithPosition(.Front)) ? AVCaptureDeviceInput(device: findCameraWithPosition(.Back)!, error: &error) : AVCaptureDeviceInput(device: findCameraWithPosition(.Front)!, error: &error)
        captureSession!.addInput(selectedDevice!)
        
        captureSession!.commitConfiguration()
        
        buttonEnabledHandler()
        
        UIView.animateWithDuration(0.5, animations: { Void in
            // If the camera is defaulted as .Back (main camera) this will always "flip" the view when the camera swaps
            self.cameraView.transform = CGAffineTransformScale(self.cameraView.transform, -1, 1)
        }, completion: { Void in
                
        })
    }
    
    /**
     *  Returns the `AVCaptureDevice` at the given position, `nil` if it is not available
     */
    func findCameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices as! [AVCaptureDevice] {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    /**
     *  Plays the specified video, it takes an NSURL to ensure the user creates the NSURL for either web or file accordingly
     */
    func previewVideo(path: NSURL) {
        NSLog("Previewing Video at path: \(path.path!)")
        if path.pathExtension == "mov" {
            let alertController = UIAlertController(title: "", message:"Preview unavailable at this time.\nYour video is still being processed.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            VideoPlayer.play(path, presentingController: self)
        }
    }
    
    /// Displays an image over the AVFoundation preview
    func displayStillImage(image: UIImage) {
        displayingStill = true
        cameraView.contentMode = .ScaleAspectFill
        cameraView.bringSubviewToFront(stillImagePreview)
        stillImagePreview.image = image
    }
    
    /// Removes the still image from view
    func removeStillImage() {
        displayingStill = false
        stillImagePreview.image = nil
        cameraView.sendSubviewToBack(stillImagePreview)
    }
    
    /*
    ** Starts the camera preview. NOT to be confused with displayStillImage
    */
    func displayImagePreview() {
        
        // Sometimes the camera shows "Loading Camera Preview..." indefinitely, we couldn't replicate it so we're assuming
        // that it was fixed. Though, if it comes up again, we think the problem might be that the app segue'd out of the camera view
        // before the preview had a chance to load (and remove properly on view will disappear)
        if (self.imageCount + self.videoCount) >= CameraView.MAX_IMAGE_COUNT {
            // no more images, display a still to be safe
            self.displayStillImage(self.imageViews[0].image!)
            return
        }
        
        // If there aren't any available cameras, leave the ViewController (must have a picture of the item to post an item)
        if findCameraWithPosition(.Front) == nil &&  findCameraWithPosition(.Back) == nil {
            let alertController = UIAlertController(title: "No Camera Available", message:"Sorry, you need to have a camera to list an item.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        captureSession!.beginConfiguration()
        
        // If the AVFoundation capture session doesn't have the selected device as an input, add a new one
        if !contains(captureSession!.inputs, item: selectedDevice) {
            captureSession!.addInput(selectedDevice!)
            
            // Check to see if the capture session supports 720p, if not, go with a preset that still supports video
            if captureSession!.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
                captureSession!.sessionPreset = AVCaptureSessionPreset1280x720
            } else {
                captureSession!.sessionPreset = AVCaptureSessionPresetHigh
            }
        }
        
        if error != nil {
            println("Error while displaying AVFoundation preview:\n\(error)")
            return
        }
        
        displayingStill = false
        
        // Create the preview layer, and add it to the screen
        capturePreview = AVCaptureVideoPreviewLayer(session: captureSession!)
        capturePreview?.frame = CGRectMake(0, 0, cameraView.layer.frame.width, cameraView.layer.frame.height)
        capturePreview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraView.layer.insertSublayer(capturePreview, below: self.flashView.layer)
        
        // If the capture session can add the stillImageOutput and it doesn't have one already, add a new output
        if captureSession!.canAddOutput(stillImageOutput) && !contains(captureSession!.outputs, item: stillImageOutput) {
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            captureSession!.addOutput(stillImageOutput)
        }
        
        // Same as still image output, but for video, minimum free disk space is just a magic number currently
        if captureSession!.canAddOutput(videoOutput) && !contains(captureSession!.outputs, item: videoOutput) {
            videoOutput.maxRecordedDuration = CMTimeMakeWithSeconds(Bakkle.sharedInstance.video_length_sec, Bakkle.sharedInstance.video_framerate)
            videoOutput.minFreeDiskSpaceLimit = 1024 * 781250 // 100 MB
            captureSession!.addOutput(videoOutput)
        }
        captureSession!.commitConfiguration()
        
        if !captureSession!.running {
            captureSession!.startRunning()
        }
    }
    
    // Called when recording begins
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        NSLog("Started Recording")
    }
    
    // A method to check if an array contains an item
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
                        // focusIndicator removeAllAnimations incase we have the indicator darken with exposure
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
    
    // Called when the UI detects a touch that has moved, used with image dragging
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touchPoint = touches.first as! UITouch
        
        if dragActivated > -1 && dragActivated < imageViews.count {
            self.dragImage(touchPoint.locationInView(self.view))
        }
    }
    
    /*
    ** If the touch is ended by the user, insert the view where it is wanted
    */
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touchPoint = touches.first as! UITouch
        
        if dragActivated > -1 && dragActivated < imageViews.count {
            self.released()
        }
    }
    
    /*
    ** If the touch is cancelled because of a system event: act as if the user didn't move the view properly
    */
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        var touchPoint = touches.first as! UITouch
        
        if dragActivated > -1 && dragActivated < imageViews.count {
            self.released()
        }
    }
    
    /// Draws a focus indicator on the focus point of the camera (if focus is available) and updates itself 32 times a second
    func drawFocusRect() {
        if selectedDevice == nil {
            return
        }
        
        // update frame of the indicator IF the device is previewing or displaying a still
        if (selectedDevice!.device.adjustingFocus || selectedDevice!.device.adjustingExposure || selectedDevice!.device.adjustingWhiteBalance) && !displayingStill && selectedDevice!.device.isFocusModeSupported(.ContinuousAutoFocus) && !stopFocus {
            
            focusIndicator.removeFromSuperview()
            focusIndicator.frame.origin.x = selectedDevice!.device.focusPointOfInterest.x * cameraView.bounds.size.width - focusIndicator.frame.width / 2.0
            focusIndicator.frame.origin.y = selectedDevice!.device.focusPointOfInterest.y * cameraView.bounds.size.height - focusIndicator.frame.height / 2.0
            cameraView.addSubview(focusIndicator)
            cameraView.bringSubviewToFront(focusIndicator)
            focusIndicator.hidden = false
        } else {
            focusIndicator.removeFromSuperview()
        }
        
        // Ensure there is only one loop running, and ends the loop when view disappears
        if !stopFocus {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((1.0/32.0) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.drawFocusRect()
            }
        }
    }
    
    // Color fix on long press for capture button
    @IBAction func pressedCaptureButton(sender: AnyObject) {
        // action event: touchDown
        self.capButton.backgroundColor = UIColor.lightGrayColor()
    }
    
    // If the capture button was released, fix the color
    @IBAction func releasedCaptureButton(sender: AnyObject) {
        // action event touchUpOutisde (also called by take photo which is up inside)
        self.capButton.backgroundColor = UIColor.whiteColor()
    }
    
    var stillRecording: UInt8 = 0
    var recordViewOutline: UIView?
    var recordView: UIView?
    var videoCount = 0
    
    // Take video after the long press was activated (can't be called more than
    @IBAction func takeVideo(sender: UILongPressGestureRecognizer) {
        if stillRecording == 0 && self.videoCount < CameraView.MAX_VIDEO_COUNT {
            stillRecording = 2
            
            /* Start Video Recording */
            var videoOutputPath = "\(NSTemporaryDirectory())video\(videoCount++).mov"
            NSLog("Temp video path: \(videoOutputPath)")
            var fileManager = NSFileManager.defaultManager()
            var error: NSError?
            
            if fileManager.fileExistsAtPath(videoOutputPath) {
                var err: NSError?
                if !fileManager.removeItemAtPath(videoOutputPath, error: &err) {
                    
                }
            }
            if self.selectedDevice!.device.flashActive {
                self.selectedDevice!.device.flashMode = AVCaptureFlashMode.Off
            }
            videoOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: videoOutputPath), recordingDelegate: self)
            
            
            /* Record View Growth */
            recordViewOutline = UIView(frame: CGRectMake(self.cameraView.frame.maxX - 60.0, self.cameraView.frame.maxY - 60.0, 50.0, 50.0))
            recordViewOutline!.backgroundColor = UIColor.darkGrayColor()
            recordViewOutline!.layer.cornerRadius = recordViewOutline!.frame.width / 2.0
            recordViewOutline!.layer.masksToBounds = true
            recordViewOutline!.alpha = 0.65
            recordViewOutline!.userInteractionEnabled = false
            self.view.addSubview(recordViewOutline!)
            
            var recordBeginWidth: CGFloat = 5.0
            recordView = UIView(frame: CGRectMake(recordViewOutline!.frame.maxX - (recordViewOutline!.frame.width / 2 + recordBeginWidth / 2.0), recordViewOutline!.frame.maxY - (recordViewOutline!.frame.width / 2  + recordBeginWidth / 2.0), recordBeginWidth, recordBeginWidth))
            recordView!.backgroundColor = UIColor.redColor()
            recordView!.layer.cornerRadius = recordView!.frame.width / 2.0
            recordView!.layer.masksToBounds = true
            recordView!.alpha = 0.75
            recordView!.userInteractionEnabled = false
            self.view.addSubview(recordView!)
            
            UIView.animateWithDuration(Bakkle.sharedInstance.video_length_sec, animations: {
                self.recordView!.transform = CGAffineTransformMakeScale(self.recordViewOutline!.frame.width / self.recordView!.frame.width, self.recordViewOutline!.frame.height / self.recordView!.frame.height)
            }, completion: { Void in
                if self.stillRecording > 0 {
                    self.finishRecording()
                }
            })
        }
    }

    // Called if the length of the video is 15 second
    func finishRecording() {
        stillRecording--
        
        self.videoOutput.stopRecording()
        
        UIView.animateWithDuration(0.05, animations: {
            self.recordView!.alpha = 0.0
            self.recordViewOutline!.alpha = 0.0
        }, completion: { Void in
            self.recordView!.removeFromSuperview()
            self.recordViewOutline!.removeFromSuperview()
        })
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        var successfulRecord = true
        
        if error != nil {
            if error!.code != 0 {
                if error.userInfo != nil {
                    var value: AnyObject? = error.userInfo![AVErrorRecordingSuccessfullyFinishedKey]
                    if value != nil {
                        successfulRecord = value!.boolValue
                    }
                }
            }
        }
        
        var err: NSError?
        
        if successfulRecord {
            if (self.imageCount + self.videoCount) >= CameraView.MAX_IMAGE_COUNT {
                self.displayStillImage(self.imageViews[0].image!)
            }
            
            var fileSize: UInt64 = 0 // this is incase the user manages to record another video before this is processed
            
            var attr: NSDictionary? = NSFileManager.defaultManager().attributesOfItemAtPath(outputFileURL.path!, error: &err)
            if let _attr = attr {
                fileSize = _attr.fileSize()
            }
            
            NSLog("Recording Finished, video\(videoCount - 1).mov size: %d bits", videoOutput.recordedFileSize)
            // Convert video to .mp4
            NSLog("Converting to MP4")
            var avAsset = AVURLAsset(URL: outputFileURL, options: nil)
            var compatiblePresets: NSArray = AVAssetExportSession.exportPresetsCompatibleWithAsset(avAsset)
            // Change this preset for quality
            var exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetLowQuality)
            
            exportSession.outputURL = NSURL(fileURLWithPath: "\(NSString(string: outputFileURL.path!).substringWithRange(NSRange(location: 0, length: count(outputFileURL.path!) - 4))).mp4")!
            
            var fileManager = NSFileManager.defaultManager()
            var error: NSError?
            
            if fileManager.fileExistsAtPath(exportSession.outputURL.path!) {
                var err: NSError?
                if !fileManager.removeItemAtPath(exportSession.outputURL.path!, error: &err) {
                    
                }
            }
            
            // Compress the video and save it as an HTML5 compatible format (.mp4)
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.outputFileType = AVFileTypeMPEG4
            NSLog("MP4 url location: \(exportSession.outputURL.path)")
            
            exportSession.exportAsynchronouslyWithCompletionHandler({ Void in
                switch (exportSession.status) {
                case AVAssetExportSessionStatus.Failed:
                    NSLog("Conversion Failed: \(exportSession.error)")
                    break
                    
                case AVAssetExportSessionStatus.Cancelled:
                    NSLog("Conversion Cancelled")
                    break
                    
                case AVAssetExportSessionStatus.Completed:
                    NSLog("Conversion Completed Successfully")
                    var movieData = NSMutableData(contentsOfFile: exportSession.outputURL.path!)
                    NSLog("MP4 Size: \(movieData?.length) bits")
                    if movieData == nil {
                        NSLog("\(exportSession.error)")
                    }
                    self.videos[self.videoCount - 1] = exportSession.outputURL
                    
                    if self.addItem != nil {
                        if self.addItem!.videos.count >= self.videoCount {
                            self.addItem!.videos[self.videoCount - 1] = exportSession.outputURL
                        } else {
                            self.addItem!.videos.append(exportSession.outputURL)
                        }
                    }
                    
                    break
                    
                default:
                    break
                }
            })
            
            
            // Get video Image
//            self.imageViews[self.imageViews.count - self.videoCount].image = Bakkle.sharedInstance.previewImageForLocalVideo(outputFileURL)
            self.videoImages[self.videoCount - 1] = Bakkle.sharedInstance.previewImageForLocalVideo(outputFileURL)!
            self.isVideo[self.imageViews.count - self.videoCount] = true
            
            if self.videos[self.videoCount - 1].pathExtension != "mp4" {
                self.videos[self.videoCount - 1] = outputFileURL
            }
            
            self.populatePhotos()
        } else {
            NSLog("RECORDING FAILED")
            self.videoCount--
        }
        
        // Possible square video link: http://www.netwalk.be/article/record-square-video-ios
    }
    
    // Capture a still image with AVFoundation
    @IBAction func takePhoto(sender: AnyObject) {
        // Logic used to determine whether the recording button was released
        // 2 == held and recording
        // 1 == done recording but held
        // 0 == done recording, not held
        if stillRecording == 2 {
            stillRecording--
            self.capButton.backgroundColor = UIColor.whiteColor()
            finishRecording()
            return
        } else if stillRecording == 1 {
            stillRecording = 0
            self.capButton.backgroundColor = UIColor.whiteColor()
            return
        }
        
        self.releasedCaptureButton(self)
        var videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // Ensure that there is still a media connection to take a picture
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
            
            // Take the picture
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
                // If the capture was successful crop the picture to the desired square and compress the image to a .jpg
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
    
    // Take an image from the gallery (UIImagePickerController)
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
    
    // UIImagePickerController finished
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var itemIndex = self.imageCount++ // set the index to imageCount then increment the total count by 1
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // Crop to the desired size and compress to a .jpg
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.buttonEnabledHandler()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Consolidates photos to the left side, ignores videos
    func populatePhotos() {
        var imagesNoSpace = [UIImage]()
        for i in 0...(self.images.count - 1) {
            if self.isVideo[i] {
                break
            }
            
            if !(self.images[i].CIImage == nil && self.images[i].CGImage == nil) {
                imagesNoSpace.append(self.images[i])
                
                if i > 0 && (self.imageViews[i - 1].image == nil) {
                    animateSlide(i, toIndex: i-1)
                } else {
                    self.imageViews[i].image = self.images[i]
                }
            }
        }
        
        var videoImagesNoSpace = [UIImage]()
        for i in (self.videoImages.count - 1)...0 {
            if !(self.videoImages[i].CIImage == nil && self.videoImages[i].CGImage == nil) {
                videoImagesNoSpace.append(self.videoImages[i])
            }
        }
        
        for i in (videoImagesNoSpace.count - 1)...0 {
            if i < 0 {
                break
            }
            
            self.imageViews[self.imageViews.count - 1 - i].image = videoImagesNoSpace[i]
        }

        
        // This is needed to stop any concurrent modification for the first for loop
        for i in 0...(self.images.count - 1) {
            self.images[i] = i >= imagesNoSpace.count ? (self.isVideo[i] ? self.images[i] : UIImage.alloc()) : imagesNoSpace[i];
        }
        
        imageCount = imagesNoSpace.count
        
        buttonEnabledHandler()
    }
    
    // Animates an image moving from one position to another and then sets the image of the new position to the image that slid
    func animateSlide(fromIndex: Int, toIndex: Int) {
        // If the index is valid and the image isn't nil
        if fromIndex < self.imageViews.count && toIndex < self.imageViews.count && fromIndex != toIndex && self.imageViews[fromIndex].image != nil {
            var startPoint = self.imageViews[fromIndex].convertPoint(self.imageViews[fromIndex].frame.origin, toView: self.view)
            var slideView = UIImageView(frame: CGRectMake(startPoint.x, startPoint.y, self.imageViews[fromIndex].frame.width, self.imageViews[fromIndex].frame.height))
            slideView.image = self.imageViews[fromIndex].image
            slideView.layer.cornerRadius = 15.0
            slideView.layer.borderColor = UIColor.whiteColor().CGColor
            slideView.layer.borderWidth = 1.0
            slideView.layer.masksToBounds = true
            self.view.addSubview(slideView)
            self.imageViews[fromIndex].image = nil
            self.lockRelease[toIndex] = true
            buttonEnabledHandler()
            animating++
            
            UIView.animateWithDuration(CameraView.IMAGE_SLIDE_ANIMATION_TIME, animations: {
                slideView.frame = CGRectMake(self.imageViewX[toIndex], self.imageViewY, slideView.frame.width, slideView.frame.height)
            }, completion: { Void in
                    self.imageViews[toIndex].image = slideView.image
                    slideView.image = nil
                    slideView.removeFromSuperview()
                    self.lockRelease[toIndex] = false
                    self.buttonEnabledHandler()
                    self.animating--
            })
        }
    }
    
    // Hides and disables buttons when needed throughout the app
    func buttonEnabledHandler() {
        var notDragging = self.dragActivated < 0
        var imageCountGreaterThanMaxCount = (imageCount + self.videoCount) >= CameraView.MAX_IMAGE_COUNT
        var recordButtonNotHeld =  !self.videoOutput.recording
        
        self.closeButton.enabled = notDragging && recordButtonNotHeld
        self.closeButton.hidden = !self.closeButton.enabled
        
        self.nextButton.enabled = imageCount > 0 && notDragging && recordButtonNotHeld
        self.nextButton.hidden = !self.nextButton.enabled
        
        self.capButton.enabled = !imageCountGreaterThanMaxCount && notDragging || self.videoOutput.recording // visible while recording
        self.galleryButton.enabled = !imageCountGreaterThanMaxCount && notDragging && recordButtonNotHeld
        self.switchCamera.enabled = !imageCountGreaterThanMaxCount && self.cameraCount > 1 && notDragging && recordButtonNotHeld
        //self.flashSettings.enabled = !imageCountGreaterThanMaxCount && selectedDevice != nil && selectedDevice!.device.hasFlash && notDragging && recordButtonHeld
        self.flashSettings.enabled = false
        
        self.capButton.hidden = !self.capButton.enabled
        self.galleryButton.hidden = !self.galleryButton.enabled
        self.switchCamera.hidden = !self.switchCamera.enabled
        self.flashSettings.hidden = !self.flashSettings.enabled
        
        self.capButtonOutline.hidden = self.capButton.hidden
        self.capButtonSpace.hidden = self.capButton.hidden
        
        for i in 0...(self.imageViews.count - 1) {
            self.removeImageButtons[i].hidden = self.imageViews[i].image == nil || !notDragging || !recordButtonNotHeld
            self.removeImageButtons[i].enabled = !self.removeImageButtons[i].hidden
        }
    }
    
    // If the user holds a photo, set it up for rearrangement and dragging
    @IBAction func photoHeld(sender: UILongPressGestureRecognizer) {
        if ((sender.view!) as! UIImageView).image != nil && self.dragActivated < 0 && !self.isVideo[sender.view!.tag - 31] {
            var newW:CGFloat = sender.view!.frame.width * 1.1
            var newH:CGFloat = sender.view!.frame.height * 1.1
            var actualBeginPt = sender.view!.convertPoint(sender.view!.frame.origin, toView: self.view)
            
            draggedImage = UIImageView(frame: CGRectMake(actualBeginPt.x, actualBeginPt.y, sender.view!.frame.width, sender.view!.frame.height))
            
            var x: CGFloat = actualBeginPt.x - (newW - sender.view!.frame.width)
            var y: CGFloat = actualBeginPt.y - (newH - sender.view!.frame.height)
            draggedImage!.layer.cornerRadius = 15.0
            draggedImage!.layer.borderColor = UIColor.whiteColor().CGColor
            draggedImage!.layer.borderWidth = 1.0
            draggedImage!.layer.masksToBounds = true
            draggedImage!.image = (sender.view! as! UIImageView).image
            draggedImage!.hidden = false
            
            dragActivated = sender.view!.tag - 31
            buttonEnabledHandler()
            
            (sender.view! as! UIImageView).image = nil
            self.view.addSubview(draggedImage!)
            
            UIView.animateWithDuration(1.0, animations: { Void in
                self.draggedImage!.frame = CGRectMake(x, y, newW, newH)
                self.draggedImage!.alpha = 0.875
            })
        }
    }
    
    // Moves the selected image to drag around the screen to the finger's position
    func dragImage(point: CGPoint) {
        if self.draggedImage != nil {
            hoverOverPosition(point)
            UIView.animateWithDuration(0.01, animations: { Void in
                self.draggedImage!.frame.origin.x = point.x - self.draggedImage!.frame.width / 2
                self.draggedImage!.frame.origin.y = point.y - self.draggedImage!.frame.height / 2
            })
        }
    }
    
    // If the finger has entered a valid position to move the image, all other images move to fix it
    func hoverOverPosition(point: CGPoint) {
        if animating > 0 {
            return
        }
        
        var i = 0
        for imageView in self.imageViews {
            var relativePoint = imageView.convertPoint(point, fromCoordinateSpace: self.view)
            
            if self.isVideo[i] {
                break
            }
            
            if CGRectContainsPoint(imageView.frame, relativePoint) {
                if self.dragActivated != i {
                    if self.imageViews[i].image == nil {
                        i = self.imageCount - 1
                    }
                    rearrangePhotos(i, previousSpace: self.dragActivated)
                    self.dragActivated = i
                }
                return
            }
            i++
        }
    }
    
    // Moves images to accomadate the given "blank" space
    func rearrangePhotos(blankSpace: Int, previousSpace: Int) {
        var increment = previousSpace > blankSpace ? -1: 1
        for i in stride(from: previousSpace, to: blankSpace, by: increment) {
            animateSlide(i + increment, toIndex: i)
        }
        
        buttonEnabledHandler()
    }
    
    // Animate the dragged image to "drop" on the selected position
    func released() {
        if self.draggedImage != nil {
            var oldDragAct = self.dragActivated
            self.dragActivated = -1
            UIView.animateWithDuration(CameraView.IMAGE_SLIDE_ANIMATION_TIME, animations: { Void in
                self.draggedImage!.frame = CGRectMake(self.imageViewX[oldDragAct], self.imageViewY, self.imageViews[oldDragAct].frame.width, self.imageViews[oldDragAct].frame.height)
                self.draggedImage!.alpha = 1.0
            }, completion: { Void in
                self.imageViews[oldDragAct].image = self.draggedImage!.image
                self.draggedImage!.removeFromSuperview()
                self.draggedImage = nil
                
                // Ensure that all animations are done before we finish releasing
                // this shouldn't need to run, though it is a failsafe
                var wait = false
                do {
                    for var i = 0; i < self.lockRelease.count && !wait; i++ {
                        wait = wait || self.lockRelease[i]
                    }
                } while(wait)
                
                // this is the same logic in populatePhotos, except it uses a different image source
                var imagesNoSpace = [UIImage]()
                for i in 0...(self.imageViews.count - 1) {
                    if self.isVideo[i] {
                        break
                    }
                    
                    if self.imageViews[i].image != nil {
                        imagesNoSpace.append(self.imageViews[i].image!)
                        self.images[i] = self.imageViews[i].image!
                    } else {
                        self.images[i] = UIImage.alloc()
                    }
                }
                
                self.imageCount = imagesNoSpace.count
                self.buttonEnabledHandler()
            })
        }
        self.dragActivated = -1
    }
    
    // Figure out which image to display after the user taps on an image
    @IBAction func photoPreview(sender: UITapGestureRecognizer) {
        // Image view tags should all be 31 higher than their position in the image view array
        // 30 represents their superview's level on the ui they are (3rd row down) 1 represents the array offset
        var imageViewIndex = sender.view!.tag - 31
        
        let validTags = [1, 10, 20, 21, 30, 31, 32, 33, 34, 40, 41, 42, 43]
        
        if imageViewIndex >= 0 && imageViewIndex < imageViews.count {
            if imageViews[imageViewIndex].image == nil && displayingStill && imageCount < CameraView.MAX_IMAGE_COUNT {
                self.removeStillImage()
            } else if imageViews[imageViewIndex].image != nil { // safety check
                if self.isVideo[imageViewIndex] {
                    self.previewVideo(self.videos[CameraView.MAX_IMAGE_COUNT - 1 - imageViewIndex])
                } else {
                    self.displayStillImage(imageViews[imageViewIndex].image!)
                }
            }
        } else {
            if !contains(validTags, item: sender.view!.tag) {
                NSLog("[CameraView] Error in photoPreview: Unknown Sender\n\(sender)")
            }
        }
    }
    
    // Remove the photo at the tapped position
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
        
        if removeImageIndex < 0 {
            NSLog("[CameraView] Error in removePhoto: Unknown Sender\n\(sender)")
        } else if imageViews[removeImageIndex].image != nil {
            var alertController: UIAlertController?
            var defaultAction = UIAlertAction(title: "NO", style: .Default, handler: nil)
            var acceptAction: UIAlertAction?
            
            // Ensure the user wants to remove the video or photo, then if they tap "YES" remove it
            if self.isVideo[removeImageIndex] {
                alertController = UIAlertController(title: "Remove Video", message: "Are you sure that you want to remove video #\(CameraView.MAX_IMAGE_COUNT - removeImageIndex)?", preferredStyle: .Alert)
                acceptAction = UIAlertAction(title: "YES", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.isVideo[removeImageIndex] = false
                    self.videoCount--
                    self.videos[CameraView.MAX_IMAGE_COUNT - removeImageIndex - 1] = NSURL()
                    self.videoImages[self.videoCount] = UIImage()
                    self.imageViews[removeImageIndex].image = nil
                    
                    self.removeVideos(CameraView.MAX_IMAGE_COUNT - removeImageIndex - 1)
                    self.buttonEnabledHandler()
                })
            } else {
                alertController = UIAlertController(title: "Remove Photo", message:"Are you sure that you want to remove image #\(removeImageIndex + 1)?", preferredStyle: .Alert)
                acceptAction = UIAlertAction(title: "YES", style: .Destructive, handler: { (action: UIAlertAction!) in
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
            }
            
            alertController!.addAction(acceptAction!)
            alertController!.addAction(defaultAction)
            presentViewController(alertController!, animated: true, completion: nil)
        }
    }
    
    // Set the proper variables in AddItem before the segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItemSegue" {
            self.populatePhotos() // to be safe
            let destinationVC = segue.destinationViewController as! AddItem
            self.addItem = destinationVC
            destinationVC.isEditting = isEditting
            
            if isEditting {
                destinationVC.item = self.item
            }
            
            var i = 0
            destinationVC.itemImages = [UIImage]()
            destinationVC.videos = [NSURL]()
            for image in self.images {
                if !(image.CIImage == nil && image.CGImage == nil) && !self.isVideo[i] {
                    destinationVC.itemImages?.append(image)
                }
                
                if i < videos.count {
                    destinationVC.videos.append(self.videos[i++])
                }
            }
        }
    }
}