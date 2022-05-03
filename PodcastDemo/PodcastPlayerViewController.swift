//
//  ViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import UIKit
import AVFoundation

class PodcastPlayerViewController: UIViewController {
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
        configPlayer()
        configBackImageView()
        configControlsView()
        configActivityIndicatorView()
        view.backgroundColor = .systemBackground
    }
    
    private func configPlayer() {
        let urlString = "https://feeds.soundcloud.com/stream/1062984568-daodutech-podcast-please-answer-daodu-tech.mp3"
        if let url = URL(string: urlString) {
            let player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            view.layer.addSublayer(playerLayer)
            
            player.play()
        }
    }
    
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

