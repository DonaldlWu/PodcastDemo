//
//  ViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/4.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configBackImageView()
        
        view.backgroundColor = .systemBackground
    }
    
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "xmark")
        return imageView
    }()
    
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

