//
//  ManagePlayersViewModelSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 04/01/16.
//  Copyright © 2016 Martin Richter. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
@testable import SwiftGoal

class ManagePlayersViewModelSpec: QuickSpec {
    override func spec() {
        describe("ManagePlayersViewModel") {
            var mockStore: MockStore!
            var managePlayersViewModel: ManagePlayersViewModel!

            beforeEach {
                mockStore = MockStore()
                managePlayersViewModel = ManagePlayersViewModel(store: mockStore, initialPlayers: [], disabledPlayers: [])
            }

            it("has the correct title") {
                expect(managePlayersViewModel.title).to(equal("Players"))
            }

            it("initially has a only single, empty section") {
                expect(managePlayersViewModel.numberOfSections()).to(equal(1))
                expect(managePlayersViewModel.numberOfPlayersInSection(0)).to(equal(0))
            }

            context("after becoming active") {
                beforeEach {
                    managePlayersViewModel.active.value = true
                }

                it("fetches a list of players") {
                    expect(mockStore.didFetchPlayers).to(beTrue())
                }

                it("has only a single section") {
                    expect(managePlayersViewModel.numberOfSections()).to(equal(1))
                }

                it("has the right number of players") {
                    expect(managePlayersViewModel.numberOfPlayersInSection(0)).to(equal(4))
                }

                it("displays the right player names") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    let indexPath3 = NSIndexPath(forRow: 2, inSection: 0)
                    let indexPath4 = NSIndexPath(forRow: 3, inSection: 0)
                    expect(managePlayersViewModel.playerNameAtIndexPath(indexPath1)).to(equal("C"))
                    expect(managePlayersViewModel.playerNameAtIndexPath(indexPath2)).to(equal("A"))
                    expect(managePlayersViewModel.playerNameAtIndexPath(indexPath3)).to(equal("D"))
                    expect(managePlayersViewModel.playerNameAtIndexPath(indexPath4)).to(equal("B"))
                }
            }

            context("when asked to refresh") {
                it("fetches a list of players") {
                    managePlayersViewModel.refreshObserver.sendNext(())
                    expect(mockStore.didFetchPlayers).to(beTrue())
                }
            }

            context("when becoming active and upon refresh") {
                it("indicates its loading state") {
                    // Aggregate loading states into an array
                    var loadingStates: [Bool] = []
                    managePlayersViewModel.isLoading.producer
                        .take(5)
                        .collect()
                        .startWithNext({ values in
                            loadingStates = values
                        })

                    managePlayersViewModel.active.value = true
                    managePlayersViewModel.refreshObserver.sendNext(())

                    expect(loadingStates).to(equal([false, true, false, true, false]))
                }

                it("notifies subscribers about content changes") {
                    var changeset: Changeset<Player>?
                    managePlayersViewModel.contentChangesSignal.observeNext { contentChanges in
                        changeset = contentChanges
                    }

                    let expectedInsertions = [
                        NSIndexPath(forRow: 0, inSection: 0),
                        NSIndexPath(forRow: 1, inSection: 0),
                        NSIndexPath(forRow: 2, inSection: 0),
                        NSIndexPath(forRow: 3, inSection: 0)
                    ]

                    managePlayersViewModel.active.value = true
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(equal(expectedInsertions))

                    managePlayersViewModel.refreshObserver.sendNext(())
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(beEmpty())
                }
            }

            it("raises an alert when players cannot be fetched") {
                mockStore.players = nil // will cause fetch error

                var didRaiseAlert = false
                managePlayersViewModel.alertMessageSignal.observeNext({ alertMessage in
                    didRaiseAlert = true
                })

                managePlayersViewModel.active.value = true

                expect(didRaiseAlert).to(beTrue())
            }
        }
    }
}
