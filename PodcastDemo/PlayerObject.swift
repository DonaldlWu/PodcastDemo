//
//  PlayerObject.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import AVFoundation

class PlayerObject: NSObject {
    private var asset: AVAsset!
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var playerItemContext = 0
    private var timeObserverToken: Any?
    
    var onPlayerReady: ((Bool) -> Void)?
    var timeOnChange: ((String) -> Void)?
    var onEpEnd: ((Bool) -> Void)?
    
    private let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    
    // Apple doc: https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/observing_playback_state
    func prepareToPlay(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        asset = AVAsset(url: url)

        playerItem = AVPlayerItem(asset: asset,
                                  automaticallyLoadedAssetKeys: requiredAssetKeys)

        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        player = AVPlayer(playerItem: playerItem)
        addPeriodicTimeObserver()
    }
    
    // apple doc: https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/observing_the_playback_time
    private func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) {
            [weak self] time in
            // update player transport UI
            self?.timeOnChange?(time.durationText)

            // Check current ep is over
            if time == self?.playerItem.duration {
                self?.onEpEnd?(true)
            }
        }
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
                self.onPlayerReady?(true)
                player.play()
            case .failed, .unknown:
                print("Some error")
            @unknown default:
                print("default")
            }
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func handleSliderWith(with value: Double) {
        if let duration = player.currentItem?.duration {
            let totalSecond = CMTimeGetSeconds(duration)
            let value = value * totalSecond

            let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
            player.seek(to: seekTime)
        }
    }
    
    func handlePlayPauseAndReturnIsPlaying() -> Bool {
        switch player.timeControlStatus {
        case .playing:
            player.pause()
            return false
        case .paused:
            player.play()
            return true
        case .waitingToPlayAtSpecifiedRate:
            return false
        @unknown default:
            return false
        }
    }
    
    func resetPlayer() {
        // Remove observer
        removePeriodicTimeObserver()
        
        // Reset parameter
        asset = nil
        player = nil
        playerItem = nil
        playerItemContext = 0
    }
    
    func getDuration() -> String {
        guard let duration = player.currentItem?.duration.durationText else { return "00:00"}
        return duration
    }
    
    deinit {
        removePeriodicTimeObserver()
    }
}

extension CMTime {
    var durationText: String {
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
