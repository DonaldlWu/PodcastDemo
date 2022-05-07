//
//  EpsiodeListViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import UIKit
import Kingfisher

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
        self.init(style: .grouped)
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        configRefreshControl()
        loadRssFeed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
        tableView.separatorStyle = .none
        tableView.register(EpsiodeCell.self, forCellReuseIdentifier: "cellId")
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tableModel = tableModel else {
            return UIImageView(image: UIImage(systemName: "xmark"))
        }
        let view = UIImageView()
        let url = URL(string: tableModel.channel.image[0].url)
        view.kf.indicatorType = .activity
        view.kf.setImage(with: url)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableModel = tableModel else {
            return 0
        }
        return tableModel.channel.item.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! EpsiodeCell
        guard let tableModel = tableModel,
              let url = URL(string: tableModel.channel.item[indexPath.row].image.href) else {
            return UITableViewCell()
        }
        let items = tableModel.channel.item
        
        cell.epImageView.kf.indicatorType = .activity
        let resource = ImageResource(downloadURL: url, cacheKey: "list_image_cache")
        cell.epImageView.kf.setImage(with: resource)
        
        cell.titleLabel.text = items[indexPath.row].title
        cell.pubDateLabel.text = items[indexPath.row].pubDate.convertDateStringForReadibility
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableModel = tableModel else { return }
        let titles = tableModel.channel.item.map { $0.title }
        let urls = tableModel.channel.item.map { $0.enclosure.url }
        let imageURLs = tableModel.channel.item.map { $0.image.href }
        let descriptions = tableModel.channel.item.map { $0.description }
        // TODO: - Map function to control mapping model(only update when tableModel update)

        let viewModel = RSSFeedViewModel(podcastTitle: tableModel.channel.title,
                                         titles: titles,
                                         urls: urls,
                                         imageURLs: imageURLs,
                                         descriptions: descriptions,
                                         playingCount: indexPath.row)
        let podDesVC = PodcastDescriptionViewController(viewModel: viewModel)
        show(podDesVC, sender: self)
    }
}

extension String {
    var convertDateStringForReadibility: String {
        return stringToDate(self)
    }
    
    private func stringToDate(_ string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ssZ"
        return dateString(date: dateFormatter.date(from: string)!)
    }
    
    private func dateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
}
