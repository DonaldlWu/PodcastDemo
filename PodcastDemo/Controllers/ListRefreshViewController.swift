//
//  ListRefreshViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//

import UIKit

final class ListRefreshViewController: NSObject {
    private let loader: RSSLoader
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(loadRssFeed), for: .valueChanged)
        return view
    }()
    
    init(loader: RSSLoader) {
        self.loader = loader
    }
    
    var onRefresh: ((RSSItem) -> Void)?
    
    @objc func loadRssFeed() {
        self.refreshControlAction(with: true)
        loader.load { [weak self] result in
            switch result {
            case let .success(rss):
                self?.onRefresh?(rss)
            case let .failure(error):
                print(error)
            }
            self?.refreshControlAction(with: false)
        }
    }
    
    private func refreshControlAction(with value: Bool) {
        DispatchQueue.main.async {
            switch value {
            case true:
                self.view.beginRefreshing()
            case false:
                self.view.endRefreshing()
            }
        }
    }
}
