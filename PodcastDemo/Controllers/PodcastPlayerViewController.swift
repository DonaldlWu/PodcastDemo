//
//  ViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import UIKit
import Kingfisher

class MockDataModel {
    let podcastTitle = "科技島讀"
    let titles = ["SP. 科技島讀請回答",
                  "Ep.145 英雄旅程最終章"]
    let urls = ["0606",
                "0530"]
    let imageURLs = ["https://i1.sndcdn.com/artworks-Z7zJRFuDjv63KCHv-5W8whA-t3000x3000.jpg",
                     "https://i1.sndcdn.com/artworks-Z7zJRFuDjv63KCHv-5W8whA-t3000x3000.jpg"]
    
    let descriptions = ["在這個最後的 Q&A 特輯中，兩位主持人回答聽眾對科技島讀與 podcast 最感興趣的問題。題目涵蓋寫作方法、發展特色、身心平衡，以及給迷惘的人的建議。\n\n科技島讀 podcast 歷時 4 年。周欽華要特別感謝盧郁青擔任共同主持人，一起同甘共苦。謝謝房首伊與賴佳翎認真負責，是可靠的後援。謝謝工程師 Joe 總是使命必達，維持系統的穩定。也謝謝聲音製作人陳繹方總是能化腐朽為神奇，把尷尬冷場的錄音剪接得流暢又生動。最後，謝謝聽眾對島讀的支持。\n\nSP：科技島讀周欽華與敏迪一起談寫作 — 敏迪選讀\nhttps://reurl.cc/NrZbRQ\n\n周欽華常用的資訊來源與受肯定的台灣個人媒體\n\n即時科技新聞\n* 科技新報 \n* iThome \n* 數位時代 \n* INSIDE \n* iKnow 科技產業資訊室 \n\n外國即時新聞\n* Techmeme \n* Hacker News \n* 彭博（Bloomberg）\n\n個人訂閱媒體\n* Stratechery（Ben Thompson）\n* Benedict Evans \n* The Diff(Byrne Hobart）\n* Dancoland（Alex Danco）\n* MatthewBall.vc\n\n台灣個人訂閱媒體\n* Manny Li 曼報（李易鴻）\n* 科技巨頭解碼（洪岳農）\n* 王伯達觀點 \n* 區塊勢（許明恩）\n* 葉郎：異聞筆記\n\nPodcast\n* The Tim Ferriss Show \n* How I Built This with Guy Raz \n* a16z \n* 馬力歐陪你喝一杯 \n* 寶博朋友說 \n* 百靈果 News \n* Gooaye 股癌 \n* 敏迪選讀",
                       "科技島讀 4 年旅程的終章，是一篇角色扮演遊戲（Role-playing game，RPG）。主角一開始努力的培養獨特的能力，奮力不被電腦替代。接著他走上創業之路。其創辦的企業一路成長，掙脫價值鏈的限制，建立護城河，最終成為壟斷性的巨頭。此時國家開始打擊他的勢力，而人民的反彈也越來越高。他也突然發現自己享受了科技的果實，卻似乎也失去了最珍貴的東西。\n\n文章：小華不平凡的科技旅程\nhttps://bit.ly/34vsqcV"]
    
    var playingCount = 1
    
    func updatePlayingCount() {
        self.playingCount -= 1
    }
    
    func returnURLString() -> String {
        return urls[playingCount]
    }
    
    func returnImageURLString() -> String {
        return imageURLs[playingCount]
    }
    
    func returnTitleString() -> String {
        return titles[playingCount]
    }
    
    func returnDescriptionString() -> String {
        return descriptions[playingCount]
    }
}

class PodcastPlayerViewController: UIViewController {
    private var viewModel: MockDataModel?
    private var player: PlayerObject?
    var onDissmiss: ((Bool) -> Void)?
    
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
    
    private let descriptionTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    convenience init(viewModel: MockDataModel, player: PlayerObject) {
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
    
    @objc private func handleSlider() {
        player?.handleSliderWith(with: Double(audioSlider.value))
    }
    
    @objc private func handlePause() {
        guard let player = player else {
            return
        }
        setPausePlayButtonImage(with: player.handlePlayPauseAndReturnIsPlaying())
    }

    deinit {
        onDissmiss?(true)
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
        
        player.prepareToPlay(urlString: viewModel.returnURLString())
        
        // Binding time change
        player.timeOnChange = { [weak self] time in
            DispatchQueue.main.async {
                self?.currentTimeLabel.text = time
            }
        }
        
        // Receiving event when Ep is ready to play
        player.onPlayerReady = { [weak self] isReady in
            self?.configUIWhenPlayerReady()
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
        player?.prepareToPlay(urlString: viewModel.returnURLString())
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
