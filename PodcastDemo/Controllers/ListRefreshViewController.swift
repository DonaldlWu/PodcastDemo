//
//  ListRefreshViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//

import UIKit

final class ListRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())
    
    private let viewModel: EpsiodeListViewModel
    
    init(viewModel: EpsiodeListViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadRssFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
