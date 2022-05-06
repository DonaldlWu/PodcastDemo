//
//  RSSLoader.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import XMLCoder
import Foundation

enum RSSLoadResult {
    case success(RSSItem)
    case failure(Error)
}

class RSSLoader {
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func load(completion: @escaping (RSSLoadResult) -> Void) {
        // TODO: - Extract client
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }

            if let data = data {
                do {
                    let rss = try XMLDecoder().decode(RSSItem.self, from: data)
                    
                    completion(.success(rss))
                } catch let (error) {
                    print(error)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "Invalid Data", code: 0)))
            }
        }
        .resume()
    }
}
