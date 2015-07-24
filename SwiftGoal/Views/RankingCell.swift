//
//  RankingCell.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit

class RankingCell: UITableViewCell {

    let playerNameLabel: UILabel
    let ratingLabel: UILabel

    // MARK: Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        playerNameLabel = UILabel()
        playerNameLabel.font = UIFont(name: "OpenSans", size: 19)

        ratingLabel = UILabel()
        ratingLabel.font = UIFont(name: "OpenSans", size: 19)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(playerNameLabel)
        contentView.addSubview(ratingLabel)

        makeConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func makeConstraints() {
        let superview = self.contentView

        playerNameLabel.snp_makeConstraints { make in
            make.leading.equalTo(superview.snp_leadingMargin)
            make.centerY.equalTo(superview.snp_centerY)
        }

        ratingLabel.snp_makeConstraints { make in
            make.leading.equalTo(playerNameLabel.snp_trailingMargin)
            make.trailing.equalTo(superview.snp_trailingMargin)
            make.centerY.equalTo(superview.snp_centerY)
        }
    }
}
