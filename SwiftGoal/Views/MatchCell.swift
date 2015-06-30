//
//  MatchCell.swift
//  SwiftGoal
//
//  Created by Martin Richter on 08/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit
import SnapKit

class MatchCell: UITableViewCell {

    let homePlayersLabel: UILabel
    let resultLabel: UILabel
    let awayPlayersLabel: UILabel

    // MARK: Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        homePlayersLabel = UILabel()
        homePlayersLabel.font = UIFont(name: "OpenSans", size: 20)
        homePlayersLabel.textAlignment = .Left

        resultLabel = UILabel()
        resultLabel.font = UIFont(name: "OpenSans-Semibold", size: 20)
        resultLabel.textAlignment = .Center

        awayPlayersLabel = UILabel()
        awayPlayersLabel.font = UIFont(name: "OpenSans", size: 20)
        awayPlayersLabel.textAlignment = .Right

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(homePlayersLabel)
        self.contentView.addSubview(resultLabel)
        self.contentView.addSubview(awayPlayersLabel)

        makeConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func makeConstraints() {
        let superview = self.contentView

        homePlayersLabel.snp_makeConstraints { make in
            make.leading.equalTo(superview.snp_leadingMargin)
            make.trailing.equalTo(resultLabel.snp_leading).offset(-10)
            make.centerY.equalTo(superview.snp_centerY)
        }

        resultLabel.snp_makeConstraints { make in
            make.centerX.equalTo(superview.snp_centerX)
            make.centerY.equalTo(superview.snp_centerY)
        }

        awayPlayersLabel.snp_makeConstraints { make in
            make.leading.equalTo(resultLabel.snp_trailing).offset(10)
            make.trailing.equalTo(superview.snp_trailingMargin)
            make.centerY.equalTo(superview.snp_centerY)
        }
    }
}
