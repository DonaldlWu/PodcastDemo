//
//  PodcastDescriptionViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/5.
//

import UIKit

class PodcastDescriptionViewController: UIViewController {
    
    let playButton: UIButton = {
        let btn = UIButton()
        btn.tintColor = .systemGray
        btn.layer.borderColor = UIColor.systemGray.cgColor
        btn.layer.borderWidth = 2
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 40
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .default)
        let image = UIImage(systemName: "play", withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(handlePlayAction), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configPlayButton()
    }
    
    @objc private func handlePlayAction() {
        let viewModel = MockDataModel()
        let player = PlayerObject()
        present(PodcastPlayerViewController(viewModel: viewModel, player: player),
                animated: true, completion: nil)
    }
    
    private func configPlayButton() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}
