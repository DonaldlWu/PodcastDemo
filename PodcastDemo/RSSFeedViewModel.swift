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
    
    init(podcastTitle: String, titles: [String], urls: [String], imageURLs: [String], descriptions: [String], playingCount: Int) {
        self.podcastTitle = podcastTitle
        self.titles = titles
        self.urls = urls
        self.imageURLs = imageURLs
        self.descriptions = descriptions
        self.playingCount = playingCount
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
