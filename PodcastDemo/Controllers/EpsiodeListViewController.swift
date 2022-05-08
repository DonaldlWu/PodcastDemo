//
//  EpsiodeListViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import UIKit
import Kingfisher

class EpsiodeListViewController: UITableViewController {
    private var refreshController: ListRefreshViewController?
    
    private var tableModel: RSSItem? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    convenience init(loader: RSSLoader) {
        self.init(style: .grouped)
        self.refreshController = ListRefreshViewController(loader: loader)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configRefreshControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func configTableView() {
        tableView.separatorStyle = .none
    }
    
    private func configRefreshControl() {
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] rss in
            self?.tableModel = rss
        }
        refreshController?.loadRssFeed()
    }
}

extension EpsiodeListViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tableModel = tableModel else {
            return UIImageView()
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
        guard let tableModel = tableModel else {
            return UITableViewCell()
        }
        let model = tableModel.channel.item[indexPath.row]
        let cellController = EpsiodeCellController(model: model)
        return cellController.view()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableModel = tableModel else { return }

        let viewModel = RSSFeedViewModel(rssItem: tableModel,
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
