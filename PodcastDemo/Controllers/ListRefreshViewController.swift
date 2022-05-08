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
                self?.refreshControlAction(with: true)
            } else {
                self?.refreshControlAction(with: false)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
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
