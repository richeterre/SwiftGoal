//
//  EditMatchViewModelSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 09/08/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftGoal

class EditMatchViewModelSpec: QuickSpec {
    override func spec() {
        describe("EditMatchViewModel") {
            var mockStore: MockStore!
            var viewModel: EditMatchViewModel!

            context("when initialized without an existing match") {
                beforeEach {
                    mockStore = MockStore()
                    viewModel = EditMatchViewModel(store: mockStore)
                }

                it("has the correct title") {
                    expect(viewModel.title).to(equal("New Match"))
                }

                it("formats the home goals correctly") {
                    viewModel.homeGoals.value = 1
                    expect(viewModel.formattedHomeGoals.value).to(equal("1"))
                }

                it("formats the away goals correctly") {
                    viewModel.awayGoals.value = 1
                    expect(viewModel.formattedAwayGoals.value).to(equal("1"))
                }

                describe("validation") {
                    it("fails initially") {
                        expect(viewModel.inputIsValid.value).to(beFalse())
                    }

                    it("fails when there are no home players") {
                        let awayPlayersViewModel = viewModel.manageAwayPlayersViewModel()
                        let awayPlayerIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                        awayPlayersViewModel.active.value = true
                        awayPlayersViewModel.selectPlayerAtIndexPath(awayPlayerIndexPath)

                        expect(viewModel.inputIsValid.value).to(beFalse())
                    }

                    it("fails when there are no away players") {
                        let homePlayersViewModel = viewModel.manageHomePlayersViewModel()
                        let homePlayerIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                        homePlayersViewModel.active.value = true
                        homePlayersViewModel.selectPlayerAtIndexPath(homePlayerIndexPath)

                        expect(viewModel.inputIsValid.value).to(beFalse())
                    }

                    it("passes when there are both home and away players") {
                        let homePlayersViewModel = viewModel.manageHomePlayersViewModel()
                        let homePlayerIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                        homePlayersViewModel.active.value = true
                        homePlayersViewModel.selectPlayerAtIndexPath(homePlayerIndexPath)

                        let awayPlayersViewModel = viewModel.manageAwayPlayersViewModel()
                        let awayPlayerIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                        awayPlayersViewModel.active.value = true
                        awayPlayersViewModel.selectPlayerAtIndexPath(awayPlayerIndexPath)

                        expect(viewModel.inputIsValid.value).to(beTrue())
                    }
                }
            }
        }
    }
}