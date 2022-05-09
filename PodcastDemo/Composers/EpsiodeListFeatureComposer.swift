//
//  EpsiodeListFeatureComposer.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//

final class EpsiodeListFeatureComposer {
    private init() {}
    
    static func ListFeatureComposerWith(loader: RSSFeedLoader) -> EpsiodeListViewController {
        let viewModel = EpsiodeListViewModel(loader: MainQueueDispatchDecorator(decoratee: loader))
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

private final class MainQueueDispatchDecorator: RSSFeedLoader {
    private let decoratee: RSSFeedLoader
    
    init(decoratee: RSSFeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (RSSLoadResult) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
        }
    }
}
