//
//  RankingsViewController.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

class RankingsViewController: UITableViewController {

    private let rankingCellIdentifier = "RankingCell"
    private let (isActiveSignal, isActiveSink) = Signal<Bool, NoError>.pipe()
    private let viewModel: RankingsViewModel

    // MARK: Lifecycle

    init(viewModel: RankingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom

        tableView.registerClass(RankingCell.self, forCellReuseIdentifier: rankingCellIdentifier)

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self,
            action: Selector("refreshControlTriggered"),
            forControlEvents: .ValueChanged
        )

        bindViewModel()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        isActiveSink.sendNext(true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        isActiveSink.sendNext(false)
    }

    // MARK: Bindings

    private func bindViewModel() {
        self.title = viewModel.title

        viewModel.active <~ isActiveSignal
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] changeset in
                self?.tableView.beginUpdates()
                self?.tableView.deleteRowsAtIndexPaths(changeset.deletions, withRowAnimation: .Left)
                self?.tableView.insertRowsAtIndexPaths(changeset.insertions, withRowAnimation: .Automatic)
                self?.tableView.endUpdates()
                })
        viewModel.isLoadingSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl?.endRefreshing()
                }
                })
        viewModel.alertMessageSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] alertMessage in
                let alertController = UIAlertController(
                    title: "Oops!",
                    message: alertMessage,
                    preferredStyle: .Alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self?.presentViewController(alertController, animated: true, completion: nil)
                })
    }

    // MARK: User Interaction

    func refreshControlTriggered() {
        viewModel.refreshSink.sendNext(())
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRankingsInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(rankingCellIdentifier, forIndexPath: indexPath) as! RankingCell

        cell.playerNameLabel.text = viewModel.playerNameAtIndexPath(indexPath)
        cell.ratingLabel.text = viewModel.ratingAtIndexPath(indexPath)

        return cell
    }
}
