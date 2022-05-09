//
//  EpsiodeCellController.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//

import UIKit
import Foundation

final class EpsiodeCellController {
    private var model: Item
    
    init(model: Item) {
        self.model = model
    }
    
    func view(in tableView: UITableView) -> EpsiodeCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! EpsiodeCell
        cell.titleLabel.text = model.title
        cell.pubDateLabel.text = model.pubDate.convertDateStringForReadibility
        
        guard let url = URL(string: model.image.href) else { return cell }
        cell.downloadImageFrom(url: url)
        
        return cell
    }
}
