//
//  EpsiodeListViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import UIKit

class EpsiodeListViewController: UITableViewController {
    private var loader: RSSLoader?
    private var tableModel: RSSItem? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    convenience init(loader: RSSLoader?) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        configRefreshControl()
        loadRssFeed()
    }
    
    @objc private func loadRssFeed() {
        startRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case let .success(rss):
                self?.tableModel = rss
            case let .failure(error):
                print(error)
            }
            self?.endRefreshing()
        }
    }
    
    private func registerCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    private func configRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadRssFeed), for: .valueChanged)
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

extension EpsiodeListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableModel = tableModel else {
            return 0
        }
        return tableModel.channel.item.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        guard let tableModel = tableModel else {
            return UITableViewCell()
        }
        cell.textLabel?.text = tableModel.channel.item[indexPath.row].title
        
        return cell
    }
}
