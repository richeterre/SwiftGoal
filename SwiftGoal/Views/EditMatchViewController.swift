//
//  EditMatchViewController.swift
//  SwiftGoal
//
//  Created by Martin Richter on 22/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit

class EditMatchViewController: UIViewController {

    let viewModel: EditMatchViewModel

    private weak var homeGoalsLabel: UILabel!
    private weak var goalSeparatorLabel: UILabel!
    private weak var awayGoalsLabel: UILabel!
    private weak var homeGoalsStepper: UIStepper!
    private weak var awayGoalsStepper: UIStepper!
    private weak var homePlayersButton: UIButton!
    private weak var awayPlayersButton: UIButton!

    private var saveAction: CocoaAction

    // MARK: Lifecycle

    init(viewModel: EditMatchViewModel) {
        self.viewModel = viewModel
        self.saveAction = CocoaAction(viewModel.saveAction, { _ in return () })
        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Cancel,
            target: self,
            action: Selector("cancelButtonTapped")
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Save,
            target: self.saveAction,
            action: CocoaAction.selector
        )
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func loadView() {
        let view = UIView()

        view.backgroundColor = UIColor.whiteColor()

        let labelFont = UIFont(name: "OpenSans-Semibold", size: 70)

        let homeGoalsLabel = UILabel()
        homeGoalsLabel.font = labelFont
        view.addSubview(homeGoalsLabel)
        self.homeGoalsLabel = homeGoalsLabel

        let goalSeparatorLabel = UILabel()
        goalSeparatorLabel.font = labelFont
        goalSeparatorLabel.text = ":"
        view.addSubview(goalSeparatorLabel)
        self.goalSeparatorLabel = goalSeparatorLabel

        let awayGoalsLabel = UILabel()
        awayGoalsLabel.font = labelFont
        view.addSubview(awayGoalsLabel)
        self.awayGoalsLabel = awayGoalsLabel

        let homeGoalsStepper = UIStepper()
        view.addSubview(homeGoalsStepper)
        self.homeGoalsStepper = homeGoalsStepper

        let awayGoalsStepper = UIStepper()
        view.addSubview(awayGoalsStepper)
        self.awayGoalsStepper = awayGoalsStepper

        let homePlayersButton = UIButton.buttonWithType(.System) as! UIButton
        homePlayersButton.addTarget(self,
            action: Selector("homePlayersButtonTapped"),
            forControlEvents: .TouchUpInside
        )
        view.addSubview(homePlayersButton)
        self.homePlayersButton = homePlayersButton

        let awayPlayersButton = UIButton.buttonWithType(.System) as! UIButton
        awayPlayersButton.addTarget(self,
            action: Selector("awayPlayersButtonTapped"),
            forControlEvents: .TouchUpInside
        )
        view.addSubview(awayPlayersButton)
        self.awayPlayersButton = awayPlayersButton

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        makeConstraints()
    }

    // MARK: Bindings

    func bindViewModel() {
        viewModel.homeGoals <~ homeGoalsStepper.signalProducer()
        viewModel.awayGoals <~ awayGoalsStepper.signalProducer()

        viewModel.formattedHomeGoals.producer
            |> startOn(UIScheduler())
            |> start(next: { [weak self] formattedHomeGoals in
                self?.homeGoalsLabel.text = formattedHomeGoals
            })

        viewModel.formattedAwayGoals.producer
            |> startOn(UIScheduler())
            |> start(next: { [weak self] formattedAwayGoals in
                self?.awayGoalsLabel.text = formattedAwayGoals
            })

        viewModel.homePlayersString.producer
            |> startOn(UIScheduler())
            |> start(next: { [weak self] homePlayersString in
                self?.homePlayersButton.setTitle(homePlayersString, forState: .Normal)
            })

        viewModel.awayPlayersString.producer
            |> startOn(UIScheduler())
            |> start(next: { [weak self] awayPlayersString in
                self?.awayPlayersButton.setTitle(awayPlayersString, forState: .Normal)
                })

        viewModel.saveAction.values.observe(next: { [weak self] success in
            if success {
                self?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alertController = UIAlertController(
                    title: "Uh oh",
                    message: "The match could not be saved.",
                    preferredStyle: .Alert
                )
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                self?.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }

    // MARK: Layout

    func makeConstraints() {
        let superview = self.view

        homeGoalsLabel.snp_makeConstraints { make in
            make.trailing.equalTo(goalSeparatorLabel.snp_leading).offset(-20)
            make.baseline.equalTo(goalSeparatorLabel.snp_baseline)
        }

        goalSeparatorLabel.snp_makeConstraints { make in
            make.center.equalTo(superview.snp_center)
        }

        awayGoalsLabel.snp_makeConstraints { make in
            make.leading.equalTo(goalSeparatorLabel.snp_trailing).offset(20)
            make.baseline.equalTo(goalSeparatorLabel.snp_baseline)
        }

        homeGoalsStepper.snp_makeConstraints { make in
            make.top.equalTo(goalSeparatorLabel.snp_baseline).offset(20)
            make.trailing.equalTo(homeGoalsLabel.snp_trailing)
        }

        awayGoalsStepper.snp_makeConstraints { make in
            make.top.equalTo(goalSeparatorLabel.snp_baseline).offset(20)
            make.leading.equalTo(awayGoalsLabel.snp_leading)
        }

        homePlayersButton.snp_makeConstraints { make in
            make.top.equalTo(homeGoalsStepper.snp_bottom).offset(40)
            make.leading.greaterThanOrEqualTo(superview.snp_leadingMargin)
            make.trailing.equalTo(homeGoalsLabel.snp_trailing)
        }

        awayPlayersButton.snp_makeConstraints { make in
            make.top.equalTo(awayGoalsStepper.snp_bottom).offset(40)
            make.leading.equalTo(awayGoalsLabel.snp_leading)
            make.trailing.lessThanOrEqualTo(superview.snp_trailingMargin)
        }
    }

    // MARK: User Interaction

    func cancelButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func homePlayersButtonTapped() {
        let homePlayersViewModel = viewModel.manageHomePlayersViewModel()
        let homePlayersViewController = ManagePlayersViewController(viewModel: homePlayersViewModel)
        self.navigationController?.pushViewController(homePlayersViewController, animated: true)
    }

    func awayPlayersButtonTapped() {
        let awayPlayersViewModel = viewModel.manageAwayPlayersViewModel()
        let awayPlayersViewController = ManagePlayersViewController(viewModel: awayPlayersViewModel)
        self.navigationController?.pushViewController(awayPlayersViewController, animated: true)
    }
}
