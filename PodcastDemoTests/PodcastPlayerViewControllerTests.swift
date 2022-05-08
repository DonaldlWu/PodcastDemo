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
        let viewModel = RSSFeedViewModel(rssItem: mockRSSItem(),
                                         playingCount: 0)
        let player = PlayerObject()
        let sut = PodcastPlayerViewController(viewModel: viewModel, player: player)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func mockRSSItem() -> RSSItem {
        return RSSItem(channel: Channel(title: "Test Title",
                                        image: [ChannelImage(url: "Test Image url")],
                                        description: "Test Des",
                                        item: [Item(title: "Item Title",
                                                    pubDate: "date",
                                                    description: "des",
                                                    enclosure: Enclosure(url: "url"),
                                                    image: ItemImage(href: "href"))]))
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak")
        }
    }

}
