//
//  RSSItem.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import Foundation

struct RSSItem: Decodable {
    let channel: Channel
}

struct Channel: Decodable {
    let title: String
    let image: [ChannelImage]
    let description: String
    let item: [Item]
}

struct ChannelImage: Decodable {
    let url: String
}

struct Enclosure: Decodable {
    let url: String
}

struct Item: Decodable {
    let title: String
    let pubDate: String
    let enclosure: Enclosure
    let image: ItemImage
    
    enum CodingKeys: String, CodingKey {
        case title
        case pubDate
        case enclosure
        case image = "itunes:image"
    }
}

struct ItemImage: Decodable {
    let href: String?
}





