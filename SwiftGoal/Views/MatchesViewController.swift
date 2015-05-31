//
//  MatchesViewController.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MatchesViewController: UITableViewController {

    let (isActiveSignal, isActiveSink) = Signal<Bool, NoError>.pipe()

    let matchCellIdentifier = "MatchCell"
    let viewModel: MatchesViewModel

    // MARK: - Lifecycle

    init(viewModel: MatchesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("NSCoding is not supported")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: matchCellIdentifier)

        bindViewModel()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        sendNext(isActiveSink, true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        sendNext(isActiveSink, false)
    }

    // MARK: - Bindings

    func bindViewModel() {
        viewModel.active <~ isActiveSignal

        self.title = viewModel.title

        viewModel.updatedContentSignal
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> observe(next: { [weak self] _ in
                self?.tableView.reloadData()
            })
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMatchesInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(matchCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = viewModel.matchAtRow(indexPath.row, inSection: indexPath.section)

        return cell
    }
}
