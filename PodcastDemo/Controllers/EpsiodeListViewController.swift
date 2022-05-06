//
//  EpsiodeListViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import UIKit

class EpsiodeListViewController: UITableViewController {
    private var loader: RSSLoader?
    
    convenience init(loader: RSSLoader?) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func loadRssFeed() {
        loader?.load { result in
            switch result {
            case let .success(rss):
                print(rss)
            case .failure:
                break
            }
        }
    }
    
}
