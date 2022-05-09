//
//  MockItem+XCTestCase.swift
//  PodcastDemoTests
//
//  Created by 吳得人 on 2022/5/9.
//

import XCTest
@testable import PodcastDemo

extension XCTestCase {
    func MockRSSItem() -> RSSItem {
        return RSSItem(channel: Channel(title: "Test Title",
                                        image: [ChannelImage(url: "Test Image url")],
                                        description: "Test Des",
                                        item: [Item(title: "Item Title",
                                                    pubDate: "date",
                                                    description: "des",
                                                    enclosure: Enclosure(url: "url"),
                                                    image: ItemImage(href: "href"))]))
    }
}
