//
//  PodcastDescriptionViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/5.
//

import UIKit
import Kingfisher

class PodcastDescriptionViewController: UIViewController {
    private var viewModel: MockDataModel?
    
    private let playButton: UIButton = {
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
    
    convenience init(viewModel: MockDataModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUILayout()
        configUIContent()
    }
    
    @objc private func handlePlayAction() {
        guard let viewModel = viewModel else {
            return
        }
        let player = PlayerObject()
        let controller = PodcastPlayerViewController(viewModel: viewModel, player: player)
        controller.onDissmiss = { [weak self] result in
            self?.configUIContent()
        }
        present(controller, animated: true, completion: nil)
    }
    
    private func configUILayout() {
        view.backgroundColor = .systemBackground
        configPlayButton()
        configBackImageView()
        configDescriptionTextView()
    }
    
    private func configUIContent() {
        DispatchQueue.main.async { [weak self] in
            self?.descriptionTextView.text = self?.viewModel?.returnDescriptionString()
            guard let url = URL(string: self?.viewModel?.returnImageURLString() ?? "") else {
                return
            }
            self?.backImageView.kf.indicatorType = .activity
            self?.backImageView.kf.setImage(with: url)
        }
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
            descriptionTextView.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -12)
        ])
    }
}
