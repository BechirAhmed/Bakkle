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
    // if you change this you need to update storyboard with an extra image view
    // and you need to add extra views to the array of image views
    private static let IMAGE_FREEZE_TIME = 0.5
    private static let FADE_IN_TIME = 0.5
    private static let IMAGE_SLIDE_ANIMATION_TIME = 0.2
    private static let FLASH_TIME = 0.05
    private static let FOCUS_SQUARE_WIDTH_SCALE: CGFloat = 1.0 / 8.0
    private static let FOCUS_SQUARE_OFFSET: CGFloat = 2.0
    static let MAX_IMAGE_COUNT = 4
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
    var stopFocus = false
    var animating: Int = 0 // image rearrangement
    
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
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
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
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        
        setupAVFoundation()
        loadingCameraPreviewLabel.hidden = false
        
        self.fadeView.alpha = 1.0
        if self.addItem != nil && (self.addItem!.successfulAdd || self.addItem!.confirmHit) {
            self.fadeViewLoadLogo.image = UIImage(named: "logo-white-design-clear.png")!
            var backgroundImage = UIImageView(frame: self.fadeView.frame)
            backgroundImage.image = UIImage(named:"LoginScreen-bkg.png")!
            self.fadeView.insertSubview(backgroundImage, belowSubview: self.fadeViewLoadLogo)
            
            // Text is set in storyboard to get a feel of orientation
            var successLabel = self.addItem!.successfulAdd ? listedLabel : willBeListedLabel
            if isEditting {
                successLabel.text = self.addItem!.successfulAdd ? "Your changes were submitted successfully!" : "Don't worry, we're still updating your changes!"
            }
            successLabel.layer.shadowColor = Theme.ColorGreen.CGColor
            successLabel.layer.shadowRadius = 5.0
            successLabel.layer.shadowOpacity = 1.0
            successLabel.hidden = false
            
            self.dismissViewControllerAnimated(true, completion: nil)
        } else if self.addItem != nil {
            self.fadeView.alpha = 0.0
        } else if isEditting {
            let imageUrls = item.valueForKey("image_urls") as! Array<String>
            for index in 0...imageUrls.count-1 {
                var imageURL: NSURL = NSURL(string: imageUrls[index])!
                var imageData: NSData = NSData(contentsOfURL: imageURL)!
                images[index] = UIImage(data: imageData)!
            }
        }
    }
    
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
        
        populatePhotos()
        
        // Any code that doesn't need the fade view active after this point
        
        if self.addItem == nil {
            UIView.animateWithDuration(CameraView.FADE_IN_TIME, animations: {
                self.fadeView.alpha = 0.0
            })
        }
        
        drawFocusRect()
    }
    
    //TEMP!! REMOVE SOON
//    func getVideoAverageSize() {
//        var avg: Double = 0.0
//        
//        for i in 0...(self.videoCount) {
//            var error: NSError?
//            var attr: NSDictionary? = NSFileManager.defaultManager().attributesOfFileSystemForPath("", error: &error)
//            if let _attr = attr {
//                avg += Double(_attr.fileSize())
//            }
//        }
//        
//        NSLog("Average file size for \(self.videoCount + 1) videos: \(avg / Double(self.videoCount + 1))")
//    }

    func calculateVideoSize() -> Double {
        var fr = Bakkle.sharedInstance.video_framerate
        var t = Bakkle.sharedInstance.video_length_sec
        
        
        
        return 0.0
    }
    
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
    
    @IBAction func cancel(sender: AnyObject) {
        self.removeVideos()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func removeVideos() {
        for i in 0...videoCount {
            var err: NSError?
            if NSFileManager.defaultManager().fileExistsAtPath("\(NSTemporaryDirectory())video\(i).mov") {
                NSFileManager.defaultManager().removeItemAtPath("\(NSTemporaryDirectory())video\(i).mov", error: &err)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loadingCameraPreviewLabel.hidden = true
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        stopFocus = true
        capturePreview?.removeFromSuperlayer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.listedLabel.hidden = true
        self.willBeListedLabel.hidden = true
    }
    
    @IBAction func swapCamera(sender: AnyObject) {
        captureSession!.beginConfiguration()
        
        captureSession!.removeInput(selectedDevice)
        selectedDevice = selectedDevice!.device.isEqual(findCameraWithPosition(.Front)) ? AVCaptureDeviceInput(device: findCameraWithPosition(.Back)!, error: &error) : AVCaptureDeviceInput(device: findCameraWithPosition(.Front)!, error: &error)
        captureSession!.addInput(selectedDevice!)
        
        captureSession!.commitConfiguration()
        
        buttonEnabledHandler()
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
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        NSLog("Started Recording")
    }
    
    func setVideoOutputProperties() {
        var captureConnection: AVCaptureConnection = videoOutput.connectionWithMediaType(AVMediaTypeVideo)
        
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
    
    func drawFocusRect() {
        if selectedDevice == nil {
            return
        }
        
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
    
    var stillRecording: UInt8 = 0
    var recordViewOutline: UIView?
    var recordView: UIView?
    var videoCount = 0
    
    @IBAction func takeVideo(sender: UILongPressGestureRecognizer) {
        if stillRecording == 0 {
            stillRecording = 2
            
            /* Start Video Recording */
            var videoOutputPath = "\(NSTemporaryDirectory())video\(videoCount++).mov"
            NSLog("Temp video path: \(videoOutputPath)")
            var fileManager = NSFileManager.defaultManager()
            var error: NSError?
            fileManager.removeItemAtPath("\(NSTemporaryDirectory())video.mov", error: &error)
            
            if fileManager.fileExistsAtPath(videoOutputPath) {
                var err: NSError?
                if !fileManager.removeItemAtPath(videoOutputPath, error: &err) {
                    // the video file is probably in use... uhh... uhh... panic. Just panic.
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
        NSLog("Recording Finished")
        
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
        
        var outputURL = "\(NSTemporaryDirectory())sqvid\(videoCount - 1)"
        
        if NSFileManager.defaultManager().fileExistsAtPath(outputURL) {
            var err: NSError?
            NSFileManager.defaultManager().removeItemAtPath(outputURL, error: &err)
        }
        
        // Pre-video editing setup
        var asset: AVAsset = AVAsset.assetWithURL(outputFileURL) as! AVAsset
        var composition = AVMutableComposition()
        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        var clipVideoTrack: AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
        
        // Crop to square
        var videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSizeMake(CGFloat(Bakkle.sharedInstance.image_width), CGFloat(Bakkle.sharedInstance.image_width))
        videoComposition.frameDuration = CMTimeMake(1, Bakkle.sharedInstance.video_framerate)
        var instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoOutput.maxRecordedDuration)
        videoComposition.instructions = [instruction]
        
        // Export
        var exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality)
        exporter.videoComposition = videoComposition
        exporter.outputURL = NSURL(fileURLWithPath: outputURL)
        exporter.outputFileType = AVFileTypeMPEG4
        
        NSLog("Pre-edited size: \(captureOutput.recordedFileSize)")
        
        exporter.exportAsynchronouslyWithCompletionHandler({
            var err: NSError?
            if NSFileManager.defaultManager().fileExistsAtPath(outputURL) {
                NSLog("Square file size: \(NSFileManager.defaultManager().attributesOfFileSystemForPath(outputURL, error: &err)![NSFileSize])")
                if err != nil {
                    NSLog(err!.localizedDescription)
                }
            }
            NSFileManager.defaultManager().removeItemAtPath(outputFileURL.lastPathComponent!, error: &err)
        })
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
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
    
    func buttonEnabledHandler() {
        var notDragging = self.dragActivated < 0
        var imageCountGreaterThanMaxCount = imageCount >= CameraView.MAX_IMAGE_COUNT
        var recordButtonNotHeld =  self.stillRecording == 0
        
        self.closeButton.enabled = notDragging && recordButtonNotHeld
        self.closeButton.hidden = !self.closeButton.enabled
        
        self.nextButton.enabled = imageCount > 0 && notDragging && recordButtonNotHeld
        self.nextButton.hidden = !self.nextButton.enabled
        
        self.capButton.enabled = !imageCountGreaterThanMaxCount && notDragging
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
            self.removeImageButtons[i].hidden = self.imageViews[i].image == nil || !notDragging || recordButtonNotHeld
            self.removeImageButtons[i].enabled = self.imageViews[i].image != nil && notDragging && recordButtonNotHeld
        }
    }
    
    // rename to long press
    @IBAction func photoHeld(sender: UILongPressGestureRecognizer) {
        if ((sender.view!) as! UIImageView).image != nil && self.dragActivated < 0 {
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
    
    func dragImage(point: CGPoint) {
        if self.draggedImage != nil {
            hoverOverPosition(point)
            UIView.animateWithDuration(0.01, animations: { Void in
                self.draggedImage!.frame.origin.x = point.x - self.draggedImage!.frame.width / 2
                self.draggedImage!.frame.origin.y = point.y - self.draggedImage!.frame.height / 2
            })
        }
    }
    
    
    
    func hoverOverPosition(point: CGPoint) {
        if animating > 0 {
            return
        }
        
        var i = 0
        for imageView in self.imageViews {
            var relativePoint = imageView.convertPoint(point, fromCoordinateSpace: self.view)
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
    
    func rearrangePhotos(blankSpace: Int, previousSpace: Int) {
        var increment = previousSpace > blankSpace ? -1: 1
        for i in stride(from: previousSpace, to: blankSpace, by: increment) {
            animateSlide(i + increment, toIndex: i)
        }
        
        buttonEnabledHandler()
    }
    
    
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
    
    @IBAction func photoPreview(sender: UITapGestureRecognizer) {
        var imageViewIndex = sender.view!.tag - 31
        
        let validTags = [1, 10, 20, 21, 30, 31, 32, 33, 34, 40, 41, 42, 43]
        
        if imageViewIndex >= 0 && imageViewIndex < imageViews.count {
            if imageViews[imageViewIndex].image == nil && displayingStill && imageCount < CameraView.MAX_IMAGE_COUNT {
                self.removeStillImage()
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
        
        if removeImageIndex < 0 {
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
            destinationVC.isEditting = isEditting
            
            if isEditting {
                destinationVC.item = self.item
            }
            
            destinationVC.itemImages = [UIImage]()
            for image in self.images {
                if !(image.CIImage == nil && image.CGImage == nil) {
                    destinationVC.itemImages?.append(image)
                }
            }
        }
    }
}