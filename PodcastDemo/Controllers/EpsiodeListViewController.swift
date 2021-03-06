//
//  EpsiodeListViewController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import UIKit
import Kingfisher

class EpisodeListViewController: UITableViewController {
    private var refreshController: ListRefreshViewController?
    var titleImageURL: urlObject?
    var tableModel: RSSItem? {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(refreshController: ListRefreshViewController) {
        self.init(style: .grouped)
        self.refreshController = refreshController
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
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: "cellId")
    }
    
    private func configRefreshControl() {
        refreshControl = refreshController?.view
        refreshController?.refresh()
    }
}

extension EpisodeListViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let object = titleImageURL, let url = URL(string: object.url) else {
            return UIImageView()
        }
        let view = UIImageView()
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
        let cellController = EpisodeCellController(model: model)
        return cellController.view(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableModel = tableModel else { return }

        let viewModel = RSSFeedViewModel(rssItem: tableModel,
                                         playingCount: indexPath.row)
        let podDesVC = PodcastDescriptionViewController(viewModel: viewModel)
        show(podDesVC, sender: self)
    }
}
