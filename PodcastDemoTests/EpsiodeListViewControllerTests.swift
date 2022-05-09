//
//  EpsiodeListViewControllerTests.swift
//  PodcastDemoTests
//
//  Created by 吳得人 on 2022/5/8.
//

import XCTest
@testable import PodcastDemo

class EpsiodeListViewControllerTests: XCTestCase {
    
    func test_loadAction_requestListFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request calls before view is load")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserTriggerReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user trigger a load")
    }
    
    func test_viewDidLoad_showLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        let item = MockRSSItem()
        loader.completeListLoading(with: item, at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completes successfully")
        
        sut.simulateUserTriggerReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator shows when user trigger a reload")
    
        loader.completeListLoading(with: item, at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user triggered loading is completes with error")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: EpsiodeListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = EpsiodeListFeatureComposer.ListFeatureComposerWith(loader: loader)
        return (sut, loader)
    }
    
    class LoaderSpy: RSSFeedLoader {
        private var completions = [(RSSLoadResult) -> Void]()
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping ((RSSLoadResult)) -> Void) {
            completions.append(completion)
        }
        
        func completeListLoading(with item: RSSItem, at index: Int) {
            completions[index](.success(item))
        }
    }
}

private extension EpsiodeListViewController {
    func simulateUserTriggerReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension EpsiodeListViewController {
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

