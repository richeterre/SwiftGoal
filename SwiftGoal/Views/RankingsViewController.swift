//
//  RankingsViewController.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit

class RankingsViewController: UITableViewController {

    private let viewModel: RankingsViewModel

    // MARK: Lifecycle

    init(viewModel: RankingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
