//
//  EpsiodeListViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import UIKit

class EpsiodeListViewController: UITableViewController {
    private let url = "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rssFeedFetchCheck()
    }
    
    private func rssFeedFetchCheck() {
        guard let url = URL(string: url) else {
            return
        }
        RSSLoader(url: url).load { result in
            switch result {
            case let .success(rss):
                print(rss)
            case .failure:
                break
            }
        }
    }
}
