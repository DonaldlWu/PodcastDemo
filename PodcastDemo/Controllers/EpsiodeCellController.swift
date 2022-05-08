//
//  EpsiodeCellController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//

import Foundation

final class EpsiodeCellController {
    private var model: Item
    
    init(model: Item) {
        self.model = model
    }
    
    func view() -> EpsiodeCell {
        let cell = EpsiodeCell()
        cell.titleLabel.text = model.title
        cell.pubDateLabel.text = model.pubDate.convertDateStringForReadibility
        
        guard let url = URL(string: model.image.href) else { return cell }
        cell.downloadImageFrom(url: url)
        
        return cell
    }
}
