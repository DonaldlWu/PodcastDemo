//
//  ViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import UIKit
import Kingfisher

class PodcastPlayerViewController: UIViewController {
    private var viewModel: RSSFeedViewModel?
    private var player: PlayerObject?
    var onEpisodeChange: ((Bool) -> Void)?
    
    // MARK: - UI element
    lazy var pausePlayButton: UIButton = {
        let btn = UIButton()
        btn.tintColor = .systemGray
        btn.layer.borderColor = UIColor.systemGray.cgColor
        btn.layer.borderWidth = 2
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 25
        btn.isHidden = true
        setPausePlayButtonImage(with: true)
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
        aiv.backgroundColor = .systemBackground
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
    
    private let descriptionTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    convenience init(viewModel: RSSFeedViewModel, player: PlayerObject) {
        self.init()
        self.viewModel = viewModel
        self.player = player
    }

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        configUILayout()
        configUIContent()
        handlePlayerBindingEvent()
    }
    
    deinit {
        self.player?.resetPlayer()
        self.player = nil
    }
    
    @objc private func handleSlider() {
        player?.handleSliderWith(with: Double(audioSlider.value))
    }
    
    @objc private func handlePause() {
        guard let player = player else {
            return
        }
        setPausePlayButtonImage(with: player.handlePlayPauseAndReturnIsPlaying())
    }

    private func configUILayout() {
        view.backgroundColor = .systemBackground
        configBackImageView()
        configControlsView()
        configActivityIndicatorView()
        configPauseButton()
        configSlider()
        configAudioLengthLabel()
        configCurrentTimeLabel()
        configDescriptionTextView()
    }
    
    private func configUIContent() {
        guard let viewModel = viewModel else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.descriptionTextView.text = viewModel.returnTitleString()
            guard let url = URL(string: viewModel.returnImageURLString()) else {
                return
            }
            self?.backImageView.kf.indicatorType = .activity
            self?.backImageView.kf.setImage(with: url)
        }
    }
    
    private func handlePlayerBindingEvent() {
        guard let viewModel = viewModel, let player = player else {
            return
        }
        
        player.prepareToPlay(with: viewModel.returnURLString())
        // TODO: Fix this by properly deal with player memory
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // Binding time change
        player.timeOnChange = { [weak self] time in
            DispatchQueue.main.async {
                self?.currentTimeLabel.text = time
            }
        }
        
        // Receiving event when Ep is ready to play
        player.onPlayerReady = { [weak self] isReady in
            self?.onEpisodeChange?(true)
            self?.configUIWhenPlayerReady()
            self?.navigationItem.setHidesBackButton(false, animated: true)
        }
        
        // Receiving event when Ep is play over
        player.onEpEnd = { [weak self] isEnd in
            // If have newer Ep, reset player and play newer Ep
            switch self?.checkPlayingCount() {
            case true:
                self?.configForNextEpsoide()
            default:
                // All ep played, just reset UI and return player to start point
                self?.stopPodcastAndResetUI()
            }
        }
    }
      
    // When Ep is downloaded, is ready to go, Update UI status
    private func configUIWhenPlayerReady() {
        activityIndicatorView.isHidden = true
        pausePlayButton.isHidden = false
        audioLengthLabel.isHidden = false
        currentTimeLabel.isHidden = false
        DispatchQueue.main.async {
            self.audioLengthLabel.text = self.player?.getDuration()
        }
    }
  
    // Reset UI status when receiving end event from player
    private func resetPlayerUI(hasNewerEp: Bool = true) {
        // Reset all setting
        audioSlider.value = 0
        activityIndicatorView.isHidden = !hasNewerEp
        pausePlayButton.isHidden = hasNewerEp
        currentTimeLabel.isHidden = hasNewerEp
        audioLengthLabel.isHidden = hasNewerEp
        setPausePlayButtonImage(with: hasNewerEp)
        DispatchQueue.main.async {
            self.currentTimeLabel.text = "00:00"
        }
    }

    private func setPausePlayButtonImage(with isPlaying: Bool) {
        DispatchQueue.main.async { [weak self] in
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .default)
            if isPlaying {
                let image = UIImage(systemName: "pause", withConfiguration: config)
                self?.pausePlayButton.setImage(image, for: .normal)
            } else {
                let image = UIImage(systemName: "play", withConfiguration: config)
                self?.pausePlayButton.setImage(image, for: .normal)
            }
        }
    }
    
    private func configForNextEpsoide() {
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.updatePlayingCount()
        resetPlayerUI()
        configUIContent()
        player?.resetPlayer()
        player?.prepareToPlay(with: viewModel.returnURLString())
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func stopPodcastAndResetUI() {
        resetPlayerUI(hasNewerEp: false)
        player?.handleSliderWith(with: 0)
    }
    
    private func checkPlayingCount() -> Bool {
        guard let viewModel = viewModel else {
            return false
        }
        return viewModel.playingCount != 0
    }
    
}

// MARK: - UI layout
extension PodcastPlayerViewController {
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
            backImageView.heightAnchor.constraint(equalToConstant: view.frame.height * (2 / 5)),
            backImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configDescriptionTextView() {
        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: backImageView.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            descriptionTextView.bottomAnchor.constraint(equalTo: currentTimeLabel.topAnchor, constant: -12)
        ])
    }

}
