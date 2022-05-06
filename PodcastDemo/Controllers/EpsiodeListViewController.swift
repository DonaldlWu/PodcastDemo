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
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadRssFeed), for: .valueChanged)
        loadRssFeed()
    }
    
    @objc private func loadRssFeed() {
        startRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case let .success(rss):
                print(rss)
            case let .failure(error):
                print(error)
            }
            self?.endRefreshing()
        }
    }
    
    private func startRefreshing() {
        DispatchQueue.main.async {
            self.refreshControl?.beginRefreshing()
        }
    }
    
    private func endRefreshing() {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
}
