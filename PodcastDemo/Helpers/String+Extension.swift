//
//  String+Extension.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/8.
//

import Foundation

extension String {
    var convertDateStringForReadibility: String {
        return stringToDate(self)
    }
    
    private func stringToDate(_ string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ssZ"
        return dateString(date: dateFormatter.date(from: string)!)
    }
    
    private func dateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
}
