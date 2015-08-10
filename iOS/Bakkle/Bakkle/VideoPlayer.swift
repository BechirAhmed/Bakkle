//
//  VideoPlayer.swift
//  Bakkle
//
//  Created by Barr, Patrick T on 8/7/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
//

import AVKit
import AVFoundation

/// A Simple class to present a video player without using storyboard.
class VideoPlayer {
    
    /// The `AVPlayer` used to display the video playback.
    private var player: AVPlayer
    
    /// The `AVPlayerViewController` used to display the `AVPlayer`.
    private var playerController: VideoPlayerViewController
    
    /// The `NSURL` that directs to teh desired video for playback.
    private var videoURL: NSURL
    
    /// The 'UIViewController' that presents the `VideoPlayer`.
    private var presentingController: UIViewController
    
    /**
     *  Initialize the VideoPlayer object.
     * 
     *  :param: videoURL `String` used to set an `NSURL` that directs to the desired video for playback.
     *  :param: presentingController `UIViewController` that instantiated the object.
     */
    init (videoURL: NSURL, presentingController: UIViewController) {
        self.player = AVPlayer(URL: videoURL)
        self.playerController = VideoPlayerViewController()
        self.videoURL = videoURL
        self.presentingController = presentingController
        
        self.playerController.player = self.player
    }
    
    /**
     *  Initialize the VideoPlayer object.
     *
     *  :param: videoURL `NSURL` that directs to the desired video for playback.
     *  :param: presentingController `UIViewController` that instantiated the object (should be `self`).
     */
    init (videoURL: String, presentingController: UIViewController) {
        self.videoURL = NSURL(string: videoURL)!
        self.player = AVPlayer(URL: self.videoURL)
        self.playerController = VideoPlayerViewController()
        self.presentingController = presentingController
        
        self.playerController.player = self.player
    }
    
    /**
     *  Presents an `AVPlayerViewController` with an `AVPlayer` and begins video playback (WEB).
     *  
     *  :param: videoURL `String` used to set an `NSURL` that directs to the desired video for playback.
     *  :param: presentingController `UIViewController` that instantiated the object.
     */
    static func playWeb(videoURL: String, presentingController: UIViewController) {
        VideoPlayer.play(NSURL(string: videoURL)!, presentingController: presentingController)
    }
    
    /**
     *  Presents an `AVPlayerViewController` with an `AVPlayer` and begins video playback (FILE).
     *
     *  :param: videoURL `String` used to set an `NSURL` that directs to the desired video for playback.
     *  :param: presentingController `UIViewController` that instantiated the object.
     */
    static func playFile(videoURL: String, presentingController: UIViewController) {
        VideoPlayer.play(NSURL(fileURLWithPath: videoURL)!, presentingController: presentingController)
    }
    
    /**
     *  Presents an `AVPlayerViewController` with an `AVPlayer` and begins video playback.
     *
     *  :param: videoURL `NSURL` that directs to the desired video for playback.
     *  :param: presentingController `UIViewController` that instantiated the object.
     */
    static func play(videoURL: NSURL, presentingController: UIViewController) {
        var player = AVPlayer(URL: videoURL)
        var playerController = VideoPlayerViewController()
        
        playerController.player = player
        
        presentingController.presentViewController(playerController, animated: true, completion: {
            player.play()
        })
    }
    
    /**
     *  Presents an `AVPlayerViewController` with an `AVPlayer` and begins video playback.
     */
    func play() {
        self.presentingController.presentViewController(self.playerController, animated: true, completion: {
            self.player.play()
        })
    }
    
    /**
     *  Returns the `AVPlayerViewController` used to display video playback.
     *
     *  :returns: `AVPlayerViewController` used to present the `AVPlayer`.
     */
    func getAVPlayerViewController() -> AVPlayerViewController {
        return self.playerController
    }
    
    /**
     *  Returns the `AVPlayer` within the `AVPlayerViewController`.
     * 
     *  :returns: `AVPlayer` used for video playback.
     */
    func getAVPlayer() -> AVPlayer {
        return self.player
    }
    
    /**
     *  Returns the `NSURL` of the current video.
     *
     *  :returns: `NSURL` currently used for video playback.
     */
    func getCurrentVideoURL() -> NSURL {
        return self.videoURL
    }
    
    /**
     *  Sets the `NSURL` for video playback.
     *
     *  :param: videoURL `String` used to set an `NSURL` that directs to the desired video for playback.
     */
    func setVideoURL(videoURL: String) {
        self.setVideoURL(NSURL(string: videoURL)!)
    }
    
    /**
     *  Sets the `NSURL` for video playback.
     *
     *  :param: videoURL `NSURL` that directs to the desired video for playback.
     */
    func setVideoURL(videoURL: NSURL) {
        self.videoURL = videoURL
    }
}

/// Private `AVPlayerViewController` to allow rotation only on itself (WIP, remove this parenthasee grouping when autorotation is complete)
class VideoPlayerViewController: AVPlayerViewController {
    
    /// Used to specify if the view should rotate or not
    private var shouldRotate: Bool = true
    
    /// Saves whether the status bar was hidden or visible from presenting controller
    private var previousStatusBarState: Bool = false
    
    /**
     *  Override method to stop autorotation after it disappears.
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.previousStatusBarState = UIApplication.sharedApplication().statusBarHidden
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    /**
     *  Override method to stop autorotation after it disappears.
     */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.setShouldRotate(false)
        UIApplication.sharedApplication().setStatusBarHidden(self.previousStatusBarState, withAnimation: .Fade)
    }
    
    /**
     *  Override method to tell the application to rotate.
     *
     *  :returns: `Bool` true if the application should autorotate.
     */
    override func shouldAutorotate() -> Bool {
        return self.shouldRotate
    }
    
    /**
     *  Set whether the device should Autorotate.
     * 
     *  :param: allowRotation `Bool` true to allow autorotation.
     */
    func setShouldRotate(allowRotation: Bool) {
        self.shouldRotate = allowRotation
    }
}