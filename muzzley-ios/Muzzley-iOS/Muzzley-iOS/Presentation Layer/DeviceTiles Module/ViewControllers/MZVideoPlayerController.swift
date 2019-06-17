//
//  MZVideoPlayerVideoController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 09/11/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

//
import Foundation
import AVFoundation

@objc protocol MZVideoPlayerControllerDelegate: NSObjectProtocol
{
    @objc optional func playerDidStartPlay()
    @objc optional func playerDidPause()
    @objc optional func playerDidStop()
    @objc optional func playerDidFinish()
}

class MZVideoPlayerController: UIViewController, VLCMediaPlayerDelegate
{
    var use_test_stream = false
    var test_stream_path = "rtsp://184.72.239.149/vod/mp4:BigBuckBunny_175k.mov"
    
    
    var delegate : MZVideoPlayerControllerDelegate?
    var componentId : String?
    var isPlaying : Bool?
    var isAudioOn : Bool?
    var isBackgroundAudioOn : Bool?
    var isVideoOn : Bool?
    var interactor : MZCameraInteractor?
    var videoPath : String?
    var audioPath : String?
    var liveFeedPath : String?
    var loadingView : MZLoadingView?
    var playerError : MZVideoPlayerAlertViewController?
    var tileVM : MZTileViewModel?
    var frame : CGRect?
    var player : VLCMediaPlayer?
    
    var videoView : UIView?
    var controlsView : UIView?
    
    var videoAlertMessage : String?
    var videoAlertHidden : Bool?
    var isLiveFeed : Bool?
    var nativeFrameSize : CGRect?
    var maximizeButton: UIButton?
    var minimizeButton: UIButton?
    var liveFeedButton: UIButton?
    
   
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    init(frame: CGRect, tileVM: MZTileViewModel, interactor: MZCameraInteractor)
    {
        super.init(nibName: nil, bundle: Bundle.main)
        
        self.interactor = interactor
        self.tileVM = tileVM
        self.nativeFrameSize = frame
        self.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height) // frame
        self.audioPath = ""
        self.videoPath = ""
        self.liveFeedPath = ""
        self.videoAlertMessage = ""
        self.videoAlertHidden = true
        self.isLiveFeed = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView = MZLoadingView()
        loadingView?.updateLoadingStatus(true, container: self.view)
        loadingView?.setLoadingText(NSLocalizedString("mobile_find_camera", comment: ""))
        playerError = MZVideoPlayerAlertViewController()
        
        self.videoView = UIView(frame: self.view!.frame)
        self.controlsView = UIView(frame: self.view!.frame)

        
        
        MZNotifications.send("StopBackgroundAudioStream", obj: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    
        isBackgroundAudioOn = false
        
        if use_test_stream
        {
            self.videoPath = test_stream_path
            self.liveFeedPath = test_stream_path
            self.audioPath = test_stream_path
            self.loadVideo(path: videoPath!, isLiveFeed: true)
        }
        else
        {
            self.interactor?.getCameraVideoPath(self.tileVM!, completion: { (path, error) in
                
                if error == nil && !path.isEmpty
                {
                    if self.videoPath != path
                    {
                        self.videoPath = path
                        self.liveFeedPath = path
                        self.loadVideo(path: path, isLiveFeed: true)
                    }
                }
                else
                {
                    self.videoPath = ""
                    self.loadingView!.updateLoadingStatus(false, container: self.view)
                    self.playerError!.updateAlertStatus(true, container: self.view, alertMessage: NSLocalizedString("mobile_video_stream_error", comment: ""))
                }
                
            })
            
            self.interactor?.getCameraAudioPath(self.tileVM!, completion: { (path, error) in
                
                if error == nil && !path.isEmpty
                {
                    self.audioPath = path
                }
                else
                {
                    self.audioPath = ""
                }
            })
            
        }
    }
    
    override func loadView() {
        self.view = UIView(frame: self.frame!)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stop()
        player = nil
        if !self.isBackgroundAudioOn!
        {
            MZNotifications.send("StopBackgroundAudioStream", obj: nil)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func applicationDidBecomeActive(notification: NSNotification)
    {
        if isBackgroundAudioOn!
        {
            self.stop()
            if videoPath != nil || !videoPath!.isEmpty
            {
                self.loadVideo(path: videoPath!, isLiveFeed: true)
            }
        }
    }
    
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        
        if player != nil
        {
            print("VLCState: \(VLCMediaPlayerStateToString(self.player!.state))")

            if(player!.state == VLCMediaPlayerState.playing)
            {
                self.videoDidStart()
                return
            }
            if player!.state == VLCMediaPlayerState.ended
            {
                if isLiveFeed! && !liveFeedPath!.isEmpty
                {
                    player = nil
                    self.loadVideo(path: liveFeedPath!, isLiveFeed: true)
                }
            }
            if player!.state == VLCMediaPlayerState.error
            {
                loadingView!.updateLoadingStatus(false, container: self.view)
                loadingView!.setLoadingText("")
                playerError!.updateAlertStatus(true, container: self.view, alertMessage: NSLocalizedString("mobile_video_stream_error", comment: ""))
            }
        }
    }
    
    func videoDidStart()
    {
        loadingView!.updateLoadingStatus(false, container: self.view)
        loadingView!.setLoadingText("")
        
        if isBackgroundAudioOn!
        {
            playerError!.updateAlertStatus(true, container: self.view, alertMessage: NSLocalizedString("mobile_background_audio_enabled_no_video", comment: ""))
            self.player!.stop()
        }
        else
        {
            setupVideoButtons(liveFeed: isLiveFeed!, fullScreenEnabled: true)
        }
    

    }
    
    func setupVideoButtons(liveFeed: Bool, fullScreenEnabled: Bool)
    {
        self.setupLiveFeedButton(show: liveFeed)
        self.setupFullscreenButtons(enabled: fullScreenEnabled)
        self.view!.addSubview(self.controlsView!)
        self.view!.bringSubview(toFront: self.controlsView!)
    }
    
    func audioDidStart(notification: NSNotification)
    {
        if isBackgroundAudioOn!
        {
            loadingView!.updateLoadingStatus(false, container: self.view)
            loadingView!.setLoadingText("")
            playerError!.updateAlertStatus(true, container: self.view, alertMessage: NSLocalizedString("mobile_background_audio_enabled_no_video", comment: ""))
        }
    }
    
    

    func loadVideo(path : String, isLiveFeed: Bool)
    {
        
        if self.player == nil
        {
            self.loadingView!.updateLoadingStatus(true, container: self.view)

            if isLiveFeed
            {
                self.loadingView?.setLoadingText(NSLocalizedString("mobile_buffering_live", comment: ""))
            }
            else
            {
                self.loadingView?.setLoadingText(NSLocalizedString("mobile_buffering", comment: ""))

            }


            self.isLiveFeed = isLiveFeed

            if self.isLiveFeed!
            {
                self.liveFeedPath = path
                self.videoPath = path
            }
            else
            {
                self.videoPath = path
            }

            self.player = VLCMediaPlayer()
            self.player!.delegate = self
            self.videoView = UIView(frame: self.view!.frame)
            self.view.addSubview(self.videoView!)
            self.player!.drawable = self.videoView
            let url = URL(string: path)

            let media = VLCMedia(url: url!)
            player!.media = media
            self.player!.play()
            self.isAudioOn = true
        }
        
    }
    
    func play()
    {
        if self.player != nil
        {
            self.player!.play()
        }
    }
    
    func stop()
    {
        if self.player != nil
        {

            self.player!.stop()
            self.player = nil
        }
    }
    
    func audio_on()
    {
        if player != nil
        {
            player!.pause()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.mixWithOthers)

                try AVAudioSession.sharedInstance().setActive(true)
                player!.play()
                self.isAudioOn = true
            } catch  {
                // TODO: Handle error
            }
        }
    }
    
    func audio_off() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            self.isAudioOn = false
        } catch {
            // TODO: Handle error
        }
    }
    
    func backgroundAudio_on()
    {
        if audioPath == nil || audioPath!.isEmpty
        {
            let alertView = UIAlertController(title: "", message: NSLocalizedString("mobile_background_audio_stream_error", comment: ""), preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
            self.present(alertView, animated: true, completion: nil)
            
            return
            // In the future, this information should be shown by the webview instead
        }
        
        setupFullscreenButtons(enabled: false)
        setupLiveFeedButton(show: false)
        isBackgroundAudioOn = true
        self.stop()
        MZNotifications.send("StartBackgroundAudioStream", obj: audioPath! as AnyObject)
        
        loadingView!.updateLoadingStatus(true, container: self.view)
        loadingView!.setLoadingText(NSLocalizedString("mobile_background_audio_loading", comment: ""))
        
    }
    
    
    func backgroundAudio_off()
    {
        if audioPath != nil || !audioPath!.isEmpty
        {
            isBackgroundAudioOn = false
            playerError?.updateAlertStatus(false, container: self.view, alertMessage: "")
            MZNotifications.send("StopBackgroundAudioStream", obj: nil)
            self.loadVideo(path: videoPath!, isLiveFeed: true)
        }
        else
        {
            // In future the webview should be informed and this won't be necessary
        }
    }
    
    func microphone_on()
    {
        self.interactor?.microphone_on(self.tileVM!)
    }
    
    func microphone_off()
    {
        self.interactor?.microphone_off()
    }
    
    func setupLiveFeedButton(show: Bool)
    {
        if show
        {
            liveFeedButton = UIButton(type: .custom)
            liveFeedButton!.contentHorizontalAlignment = .left
            liveFeedButton!.contentVerticalAlignment = .top
            let liveFeedImage = UIImage(named: "icon_live_view")
            liveFeedButton!.setImage(liveFeedImage, for: .normal)
            liveFeedButton!.frame = CGRect(x: 15,y: 15,width: 35,height: 35)
            self.controlsView!.addSubview(liveFeedButton!)
        }
        else
        {
            self.liveFeedButton?.removeFromSuperview()
        }
    }
    
    func setupFullscreenButtons(enabled: Bool)
    {
        if enabled
        {
            maximizeButton = UIButton(type: .custom)
            maximizeButton!.addTarget(self, action: #selector(fullscreen_on), for: .touchUpInside)
            maximizeButton!.contentHorizontalAlignment = .right
            maximizeButton!.contentVerticalAlignment = .bottom
            maximizeButton!.setTitle("fullscreen", for: .normal)
            
            let maximizeImage = UIImage(named: "icon_maximize")
            maximizeButton!.setImage(maximizeImage, for: .normal)
            maximizeButton!.frame = CGRect(x: UIScreen.main.bounds.size.width - 40, y:nativeFrameSize!.size.height -  40, width: 20, height: 20)
            self.controlsView!.addSubview(maximizeButton!)

            minimizeButton = UIButton(type: .custom)
            minimizeButton!.addTarget(self, action: #selector(fullscreen_off), for: .touchUpInside)
            minimizeButton!.contentHorizontalAlignment = .right
            minimizeButton!.contentVerticalAlignment = .bottom
            
            let minimizeImage = UIImage(named: "icon_minimize")
            minimizeButton!.setImage(minimizeImage, for: .normal)
            minimizeButton!.frame = CGRect(x: UIScreen.main.bounds.size.height - 40, y:UIScreen.main.bounds.size.width -  40, width: 20, height: 20)
            
            
        }
        else
        {
            if maximizeButton != nil
            {
                maximizeButton!.removeFromSuperview()
            }
            if minimizeButton != nil
            {
                minimizeButton!.removeFromSuperview()
            }
        }
    }
    
    func fullscreen_on()
    {
        maximizeButton?.removeFromSuperview()
        
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        self.view!.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        self.view!.center = (UIApplication.shared.keyWindow?.center)!
        
        UIApplication.shared.keyWindow?.addSubview(self.view!)
        
        self.videoView!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        self.controlsView!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)

        
        self.controlsView!.addSubview(minimizeButton!)
    }
    
    func fullscreen_off()
    {
        minimizeButton!.removeFromSuperview()
        
        self.view!.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 2))
        self.view!.frame = CGRect(x: 0, y: self.nativeFrameSize!.origin.y, width: UIScreen.main.bounds.size.width, height: frame!.size.height)
    
        self.controlsView!.addSubview(maximizeButton!)
        
        self.videoView!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: nativeFrameSize!.size.height)
        self.controlsView!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: nativeFrameSize!.size.height)

    }
    
}
