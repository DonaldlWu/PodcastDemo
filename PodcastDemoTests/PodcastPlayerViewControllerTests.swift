//
//  PodcastDemoTests.swift
//  PodcastDemoTests
//
//  Created by 吳得人 on 2022/5/4.
//

import XCTest
@testable import PodcastDemo

class PodcastPlayerViewControllerTests: XCTestCase {
    
    func test_init_deinitCorrectly() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
    }
    
    // MARK: - Helpers
    private func makeSUT() -> PodcastPlayerViewController {
        let viewModel = RSSFeedViewModel(rssItem: MockRSSItem(),
                                         playingCount: 0)
        let player = PlayerObject()
        let sut = PodcastPlayerViewController(viewModel: viewModel, player: player)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak")
        }
    }

}
