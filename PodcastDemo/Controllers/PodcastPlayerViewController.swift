//
//  ViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import UIKit

class PodcastPlayerViewController: UIViewController {
    private var player = PlayerObject()
    
    // MARK: - UI element
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
    
    private let audioLengthLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.textColor = .label
        lbl.textAlignment = .right
        lbl.isHidden = true
        return lbl
    }()
    
    private let currentTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.textColor = .label
        lbl.textAlignment = .left
        lbl.isHidden = true
        return lbl
    }()
    
    private lazy var audioSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .systemGray
        slider.addTarget(self, action: #selector(handleSlider), for: .allEvents)
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

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configPlayer()
    }
    
    @objc private func handleSlider() {
        player.handleSliderWith(with: Double(audioSlider.value))
    }
    
    @objc private func handlePause() {
        setPausePlayButtonImage(with: player.handlePlayPauseAndReturnIsPlaying())
    }
    
    private func configUI() {
        view.backgroundColor = .systemBackground
        configBackImageView()
        configControlsView()
        configActivityIndicatorView()
        configPauseButton()
        configSlider()
        configAudioLengthLabel()
        configCurrentTimeLabel()
    }
    
    private func configPlayer() {
        player.prepareToPlay()
        
        // Binding
        player.timeOnChange = { [weak self] time in
            DispatchQueue.main.async {
                self?.currentTimeLabel.text = time
            }
        }
        player.onPlayerReady = { isReady in
            self.configUIWhenPlayerReady()
        }
        
        player.onEpEnd = { isEnd in
            self.audioSlider.value = 0
            self.resetPlayerUI()
        }
    }
    
    private func resetPlayerUI() {
        // Reset all setting
        player.resetPlayer()
        
        player.prepareToPlay()
        audioSlider.value = 0
        setPausePlayButtonImage(with: false)
        DispatchQueue.main.async {
            self.currentTimeLabel.text = "00:00"
        }
    }

    private func setPausePlayButtonImage(with isPlaying: Bool) {
        DispatchQueue.main.async {
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .default)
            if isPlaying {
                let image = UIImage(systemName: "pause", withConfiguration: config)
                self.pausePlayButton.setImage(image, for: .normal)
            } else {
                let image = UIImage(systemName: "play", withConfiguration: config)
                self.pausePlayButton.setImage(image, for: .normal)
            }
        }
    }
    
    private func configUIWhenPlayerReady() {
        activityIndicatorView.isHidden = true
        pausePlayButton.isHidden = false
        audioLengthLabel.isHidden = false
        currentTimeLabel.isHidden = false
        DispatchQueue.main.async {
            self.audioLengthLabel.text = self.player.getDuration()
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
        setPausePlayButtonImage(with: false)
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
            audioLengthLabel.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func configCurrentTimeLabel() {
        controlsContainView.addSubview(currentTimeLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentTimeLabel.leadingAnchor.constraint(equalTo: audioSlider.leadingAnchor),
            currentTimeLabel.bottomAnchor.constraint(equalTo: audioSlider.topAnchor, constant: 4),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 50),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 120)
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
