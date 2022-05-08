//
//  ListViewModel.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//


final class EpsiodeListViewModel {
    private let loader: RSSFeedLoader
    
    init(loader: RSSFeedLoader) {
        self.loader = loader
    }
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    var onChange: ((EpsiodeListViewModel) -> Void)?
    var onRSSLoaded: ((RSSItem) -> Void)?
    
    func loadRssFeed() {
        isLoading = true
        loader.load { [weak self] result in
            switch result {
            case let .success(rss):
                self?.onRSSLoaded?(rss)
            case let .failure(error):
                // TODO: - Error handling
                print(error)
            }
            self?.isLoading = false
        }
    }
}
