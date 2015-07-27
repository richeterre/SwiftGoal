//
//  MatchesViewController.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import ReactiveCocoa

class MatchesViewController: UITableViewController, DZNEmptyDataSetSource {

    private let matchCellIdentifier = "MatchCell"
    private let (isActiveSignal, isActiveSink) = Signal<Bool, NoError>.pipe()
    private let viewModel: MatchesViewModel

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

        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom

        tableView.emptyDataSetSource = self

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self,
            action: Selector("refreshControlTriggered"),
            forControlEvents: .ValueChanged
        )

        tableView.registerClass(MatchCell.self, forCellReuseIdentifier: matchCellIdentifier)

        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: Selector("addMatchButtonTapped")
        )

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

    private func bindViewModel() {
        self.title = viewModel.title

        viewModel.active <~ isActiveSignal
        viewModel.contentChangesSignal
            |> observeOn(UIScheduler())
            |> observe(next: { [weak self] changeset in
                self?.tableView.beginUpdates()
                self?.tableView.deleteRowsAtIndexPaths(changeset.deletions, withRowAnimation: .Left)
                self?.tableView.insertRowsAtIndexPaths(changeset.insertions, withRowAnimation: .Automatic)
                self?.tableView.endUpdates()
            })
        viewModel.isLoadingSignal
            |> observeOn(UIScheduler())
            |> observe(next: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl?.endRefreshing()
                }
            })
        viewModel.alertMessageSignal
            |> observeOn(UIScheduler())
            |> observe(next: { [weak self] alertMessage in
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

    func addMatchButtonTapped() {
        let newMatchViewModel = viewModel.editViewModelForNewMatch()
        let newMatchViewController = EditMatchViewController(viewModel: newMatchViewModel)
        let newMatchNavigationController = UINavigationController(rootViewController: newMatchViewController)
        self.presentViewController(newMatchNavigationController, animated: true, completion: nil)
    }

    func refreshControlTriggered() {
        sendNext(viewModel.refreshSink, ())
    }

    // MARK: DZNEmptyDataSetSource

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No matches yet!"
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 30)!
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Tap the Add button at the top-right corner to get started."
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 20)!,
            NSForegroundColorAttributeName: UIColor.lightGrayColor()
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMatchesInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(matchCellIdentifier, forIndexPath: indexPath) as! MatchCell

        cell.homePlayersLabel.text = viewModel.homePlayersAtIndexPath(indexPath)
        cell.resultLabel.text = viewModel.resultAtIndexPath(indexPath)
        cell.awayPlayersLabel.text = viewModel.awayPlayersAtIndexPath(indexPath)

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            viewModel.deleteAction.apply(indexPath).start()
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let editMatchViewModel = viewModel.editViewModelForMatchAtIndexPath(indexPath)
        let editMatchViewController = EditMatchViewController(viewModel: editMatchViewModel)
        let editMatchNavigationController = UINavigationController(rootViewController: editMatchViewController)
        self.presentViewController(editMatchNavigationController, animated: true, completion: nil)
    }
}
