//
//  ViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import UIKit
import AVFoundation

class PodcastPlayerViewController: UIViewController {
    private var asset: AVAsset!
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var playerItemContext = 0
    private let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]

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
        
        prepareToPlay()
        view.backgroundColor = .systemBackground
    }
    
    // Apple doc: https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/observing_playback_state
    func prepareToPlay() {
        let urlString = "https://feeds.soundcloud.com/stream/1062984568-daodutech-podcast-please-answer-daodu-tech.mp3"
        guard let url = URL(string: urlString) else { return }
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
                player.play()
            case .failed:
                activityIndicatorView.isHidden = false
                print("Some error")
            case .unknown:
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

