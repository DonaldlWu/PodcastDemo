//
//  EpsiodeCell.swift
//  PodcastDemo
//
//  Created by 吳得人 on 2022/5/6.
//

import UIKit

class EpsiodeCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let pubDateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        return lbl
    }()
    
    let epImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    private func configUI() {
        addSubviews([titleLabel,
                     pubDateLabel,
                     epImageView])
        
        layoutEpImageView()
        layoutTitleLabel()
        layoutPubDateLabel()
    }
    
    private func layoutEpImageView() {
        NSLayoutConstraint.activate([
            epImageView.widthAnchor.constraint(equalToConstant: 80),
            epImageView.heightAnchor.constraint(equalToConstant: 80),
            epImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            epImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            epImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    private func layoutTitleLabel() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: epImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: epImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    private func layoutPubDateLabel() {
        NSLayoutConstraint.activate([
            pubDateLabel.bottomAnchor.constraint(equalTo: epImageView.bottomAnchor),
            pubDateLabel.leadingAnchor.constraint(equalTo: epImageView.trailingAnchor, constant: 8),
            pubDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8),
        ])
    }
    
    private func addSubviews(_ views: [UIView]) {
        views.forEach { view in
            contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
