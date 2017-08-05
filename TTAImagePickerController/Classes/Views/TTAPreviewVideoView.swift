//
//  TTAPreviewVideoView.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 04/08/2017.
//

import AVFoundation

class TTAPreviewVideoView: UIControl {
    
    weak var tapDelegate: TTAPreviewContentViewDelegate?
    
    fileprivate let player = AVPlayer()
    fileprivate let playerLayer = AVPlayerLayer()
    fileprivate let playPauseButton = UIButton(type: .custom)
    fileprivate let videoProgressView = TTAVideoProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
}

// MARK: - UI

fileprivate extension TTAPreviewVideoView {
    func setupUI() {
        func createViews() {
            layer.addSublayer(playerLayer)
            addSubview(playPauseButton)
            addSubview(videoProgressView)
        }
        
        func configViews() {
            playPauseButton.addTarget(self, action: #selector(didClickPlayPauseButton), for: .touchUpInside)
            playPauseButton.setTitleColor(.white, for: .normal)
            playPauseButton.setTitleColor(.white, for: .selected)
            playPauseButton.setTitle(UIFont.IconFont.playMark.rawValue, for: .normal)
            playPauseButton.setTitle(UIFont.IconFont.pauseMark.rawValue, for: .selected)
            playPauseButton.titleLabel?.font = UIFont.iconfont(size: UIFont.IconFontSize.playMark)
            
            videoProgressView.delegate = self
            videoProgressView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
            addGestureRecognizer(tap)
            
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1),
                                           queue: DispatchQueue.main) { [weak self] (cmtime) in
                                            guard let `self` = self,
                                                self.player.status == .readyToPlay,
                                                let currentItem = self.player.currentItem else { return }
                                            let currentTime = CMTimeGetSeconds(cmtime)
                                            let duration = CMTimeGetSeconds(currentItem.asset.duration)
                                            let videoInfo = TTAVideoProgressViewInfo(current: currentTime, duration: duration)
                                            self.videoProgressView.update(with: videoInfo)
            }
        }
        createViews()
        configViews()
    }
    
    func layoutViews() {
        playerLayer.frame = bounds
        playPauseButton.frame = CGRect(x: (bounds.width - UIFont.IconFontSize.playMark) / 2,
                                       y: (bounds.height - UIFont.IconFontSize.playMark) / 2,
                                       width: UIFont.IconFontSize.playMark,
                                       height: UIFont.IconFontSize.playMark)
        videoProgressView.frame = CGRect(x: 0,
                                         y: bounds.height - TTAVideoProgressView.height(),
                                         width: bounds.width,
                                         height: TTAVideoProgressView.height())
    }
}

// MARK: - Actions

extension TTAPreviewVideoView {
    func didClickPlayPauseButton() {
        playPauseButton.isSelected = !playPauseButton.isSelected
        if playPauseButton.isSelected {
            playVideo()
        } else {
            pauseVideo()
        }
        tapDelegate?.tappedPreviewContentView(self)
    }
    
    func didTap(tap: UITapGestureRecognizer) {
        guard tap.state == .ended else { return }
        tapDelegate?.tappedPreviewContentView(self)
        guard playPauseButton.alpha < 1 else { return }
        showPlayPauseButton()
        perform(#selector(hiddenPlayPauseButton), with: nil, afterDelay: animationDelay())
    }
    
    func didVideoPlayToEnd() {
        didClickPlayPauseButton()
        player.seek(to: kCMTimeZero)
    }
    
    func playVideo() {
        player.play()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didVideoPlayToEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        hiddenPlayPauseButton()
    }
    
    func pauseVideo() {
        player.pause()
        NotificationCenter.default.removeObserver(self)
        showPlayPauseButton()
    }
}

// MARK: - Private Methods

extension TTAPreviewVideoView {
    func hiddenPlayPauseButton() {
        guard playPauseButton.isSelected else { return }
        UIView.animate(withDuration: animationDuration(),
                       delay: animationDelay(),
                       options: .allowUserInteraction,
                       animations: { [weak self] in
            guard let `self` = self else { return }
            self.playPauseButton.alpha = 0
        })
    }
    
    func showPlayPauseButton() {
        UIView.animate(withDuration: animationDuration(), delay: 0, options: .allowUserInteraction, animations: { [weak self] in
            guard let `self` = self else { return }
            self.playPauseButton.alpha = 1
        })
    }
}

// MARK: - Public Methods

extension TTAPreviewVideoView {
    func update(with playerItem: AVPlayerItem?) {
        player.replaceCurrentItem(with: playerItem)
        playerLayer.player = player
    }
}

// MARK: - Const

extension TTAPreviewVideoView {
    func animationDelay() -> TimeInterval {
        return 1
    }
    
    func animationDuration() -> TimeInterval {
        return 1
    }
}

extension TTAPreviewVideoView: TTAVideoProgressViewDelegate {
    func videoProgressView(_ progressView: TTAVideoProgressView, seekTo percent: Double) {
        guard player.status == .readyToPlay,
            let currentItem = player.currentItem else { return }
        player.seek(to: CMTime(seconds: percent * CMTimeGetSeconds(currentItem.duration), preferredTimescale: 1))
    }
}

// MARK: - TTAPreviewContentViewCompatiable

extension TTAPreviewVideoView: TTAPreviewContentViewCompatiable {}
