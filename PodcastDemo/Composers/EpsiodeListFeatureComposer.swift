//
//  EpsiodeListFeatureComposer.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//

final class EpsiodeListFeatureComposer {
    private init() {}
    
    static func ListFeatureComposerWith(loader: RSSFeedLoader) -> EpsiodeListViewController {
        let viewModel = EpsiodeListViewModel(loader: loader)
        let refreshController = ListRefreshViewController(viewModel: viewModel)
        let epsiodeViewController = EpsiodeListViewController(refreshController: refreshController)
        viewModel.onRSSLoaded = { rss in
            epsiodeViewController.tableModel = rss
            let ocObject = urlObject.init()
            ocObject.url = rss.channel.image[0].url
            epsiodeViewController.titleImageURL = ocObject
        }
        
        return epsiodeViewController
    }
}