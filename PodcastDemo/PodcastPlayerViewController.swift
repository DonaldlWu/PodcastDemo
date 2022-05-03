//
//  ViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import UIKit
import AVFoundation

class PodcastPlayerViewController: UIViewController {
    private var isPlaying = false
    private var asset: AVAsset!
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var playerItemContext = 0
    private var timeObserverToken: Any?
    
    private let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    
    lazy var pausePlayButton: UIButton = {
        let btn = UIButton()
        btn.tintColor = .systemGray
        btn.layer.borderColor = UIColor.systemGray.cgColor
        btn.layer.borderWidth = 2
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 25
        btn.isHidden = true
        btn.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return btn
    }()
    
    let audioLengthLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.textColor = .label
        lbl.textAlignment = .center
        lbl.isHidden = true
        return lbl
    }()
    
    let currentTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.textColor = .label
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var audioSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .systemGray
        slider.addTarget(self, action: #selector(handleSlider), for: .touchUpInside)
        return slider
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.backgroundColor = .white
        aiv.startAnimating()
        return aiv
    }()
    
    private let controlsContainView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "xmark")
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configBackImageView()
        configControlsView()
        configActivityIndicatorView()
        configPauseButton()
        configSlider()
        configAudioLengthLabel()
        configCurrentTimeLabel()
        
        prepareToPlay()
        view.backgroundColor = .systemBackground
        
        addPeriodicTimeObserver()
    }
    
    deinit {
        removePeriodicTimeObserver()
    }
    
    @objc private func handleSlider() {
        if let duration = player.currentItem?.duration {
            let totalSecond = CMTimeGetSeconds(duration)
            let value = Double(audioSlider.value) * totalSecond
            
            let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
            player.seek(to: seekTime)
        }
    }
    
    @objc private func handlePause() {
        if isPlaying {
            player.pause()
            setPausePlayButtonImage()
        } else {
            player.play()
            setPausePlayButtonImage()
        }
        isPlaying = !isPlaying
    }
    
    // apple doc: https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/observing_the_playback_time
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) {
            [weak self] time in

            // update player transport UI
            self?.currentTimeLabel.text = time.durationText
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func setPausePlayButtonImage() {
        DispatchQueue.main.async {
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .default)
            if self.isPlaying {
                let image = UIImage(systemName: "pause", withConfiguration: config)
                self.pausePlayButton.setImage(image, for: .normal)
            } else {
                let image = UIImage(systemName: "play", withConfiguration: config)
                self.pausePlayButton.setImage(image, for: .normal)
            }
        }
    }
    
    // Apple doc: https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/observing_playback_state
    func prepareToPlay() {
        let url = Bundle.main.url(forResource: "0606", withExtension: "mp3")!

//        let urlString = "https://feeds.soundcloud.com/stream/1062984568-daodutech-podcast-please-answer-daodu-tech.mp3"
//        guard let url = URL(string: urlString) else { return }
        asset = AVAsset(url: url)

        playerItem = AVPlayerItem(asset: asset,
                                  automaticallyLoadedAssetKeys: requiredAssetKeys)

        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        player = AVPlayer(playerItem: playerItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                activityIndicatorView.isHidden = true
                pausePlayButton.isHidden = false
                audioLengthLabel.isHidden = false
                if let duration = player.currentItem?.duration.durationText {
                    DispatchQueue.main.async {
                        self.audioLengthLabel.text = duration
                    }
                }
            case .failed, .unknown:
                activityIndicatorView.isHidden = false
                print("Some error")
            @unknown default:
                print("default")
            }
        }
    }
    
    // MARK: - UI layout
    private func configControlsView() {
        view.addSubview(controlsContainView)
        controlsContainView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            controlsContainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsContainView.heightAnchor.constraint(equalToConstant: 200),
            controlsContainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    private func configActivityIndicatorView() {
        controlsContainView.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: controlsContainView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: controlsContainView.centerYAnchor)
        ])
    }

    private func configPauseButton() {
        controlsContainView.addSubview(pausePlayButton)
        setPausePlayButtonImage()
        pausePlayButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pausePlayButton.centerXAnchor.constraint(equalTo: controlsContainView.centerXAnchor),
            pausePlayButton.centerYAnchor.constraint(equalTo: controlsContainView.centerYAnchor),
            pausePlayButton.heightAnchor.constraint(equalToConstant: 50),
            pausePlayButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configAudioLengthLabel() {
        controlsContainView.addSubview(audioLengthLabel)
        audioLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            audioLengthLabel.trailingAnchor.constraint(equalTo: audioSlider.trailingAnchor),
            audioLengthLabel.bottomAnchor.constraint(equalTo: audioSlider.topAnchor, constant: 4),
            audioLengthLabel.heightAnchor.constraint(equalToConstant: 50),
            audioLengthLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configCurrentTimeLabel() {
        controlsContainView.addSubview(currentTimeLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentTimeLabel.leadingAnchor.constraint(equalTo: audioSlider.leadingAnchor),
            currentTimeLabel.bottomAnchor.constraint(equalTo: audioSlider.topAnchor, constant: 4),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 50),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configSlider() {
        controlsContainView.addSubview(audioSlider)
        audioSlider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            audioSlider.topAnchor.constraint(equalTo: controlsContainView.topAnchor, constant: 16),
            audioSlider.heightAnchor.constraint(equalToConstant: 30),
            audioSlider.leadingAnchor.constraint(equalTo: controlsContainView.leadingAnchor, constant: 24),
            audioSlider.trailingAnchor.constraint(equalTo: controlsContainView.trailingAnchor, constant: -24)
        ])
    }
    
    private func configBackImageView() {
        view.addSubview(backImageView)
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backImageView.heightAnchor.constraint(equalToConstant: view.frame.width * (9 / 16)),
            backImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}

extension CMTime {
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
