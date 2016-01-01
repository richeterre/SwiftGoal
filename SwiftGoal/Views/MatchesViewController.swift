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

class MatchesViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    private let matchCellIdentifier = "MatchCell"
    private let (isActiveSignal, isActiveObserver) = Signal<Bool, NoError>.pipe()
    private let viewModel: MatchesViewModel

    // MARK: - Lifecycle

    init(viewModel: MatchesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding is not supported")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom

        tableView.emptyDataSetDelegate = self
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

        isActiveObserver.sendNext(true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        isActiveObserver.sendNext(false)
    }

    // MARK: - Bindings

    private func bindViewModel() {
        self.title = viewModel.title

        viewModel.active <~ isActiveSignal

        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] changeset in
                guard let tableView = self?.tableView else { return }

                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(changeset.deletions, withRowAnimation: .Automatic)
                tableView.reloadRowsAtIndexPaths(changeset.modifications, withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths(changeset.insertions, withRowAnimation: .Automatic)
                tableView.endUpdates()
            })

        viewModel.isLoading.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self] isLoading in
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

    func addMatchButtonTapped() {
        let newMatchViewModel = viewModel.editViewModelForNewMatch()
        let newMatchViewController = EditMatchViewController(viewModel: newMatchViewModel)
        let newMatchNavigationController = UINavigationController(rootViewController: newMatchViewController)
        self.presentViewController(newMatchNavigationController, animated: true, completion: nil)
    }

    func refreshControlTriggered() {
        viewModel.refreshObserver.sendNext(())
    }

    // MARK: DZNEmptyDataSetDelegate

    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(settingsURL)
        }
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
        let text = "Check your storage settings, then tap the “+” button to get started."
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 20)!,
            NSForegroundColorAttributeName: UIColor.lightGrayColor()
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }

    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let text = "Open App Settings"
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 20)!,
            NSForegroundColorAttributeName: (state == .Normal
                ? Color.primaryColor
                : Color.lighterPrimaryColor)
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
