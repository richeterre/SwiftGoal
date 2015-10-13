//
//  PlayerCell.swift
//  SwiftGoal
//
//  Created by Martin Richter on 30/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit

class PlayerCell: UITableViewCell {

    let nameLabel: UILabel

    // MARK: Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: "OpenSans", size: 19)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(nameLabel)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func makeConstraints() {
        let superview = self.contentView

        nameLabel.snp_makeConstraints { make in
            make.leading.equalTo(superview.snp_leadingMargin)
            make.trailing.equalTo(superview.snp_trailingMargin)
            make.centerY.equalTo(superview.snp_centerY)
        }
    }
}
