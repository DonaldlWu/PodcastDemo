//
//  RSSFeedViewModel.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import Foundation

class RSSFeedViewModel {
    let podcastTitle: String
    let titles: [String]
    let urls: [String]
    let imageURLs: [String]
    let descriptions: [String]
    var playingCount: Int
    
    init(rssItem: RSSItem, playingCount: Int) {
        self.playingCount = playingCount
        self.podcastTitle = rssItem.channel.title
        self.titles = rssItem.channel.item.map { $0.title }
        self.urls = rssItem.channel.item.map { $0.enclosure.url }
        self.imageURLs = rssItem.channel.item.map { $0.image.href }
        self.descriptions = rssItem.channel.item.map { $0.description }
    }
    func updatePlayingCount() {
        self.playingCount -= 1
    }
    
    func returnURLString() -> String {
        return urls[playingCount]
    }
    
    func returnImageURLString() -> String {
        return imageURLs[playingCount]
    }
    
    func returnTitleString() -> String {
        return titles[playingCount]
    }
    
    func returnDescriptionString() -> String {
        return descriptions[playingCount]
    }
}
