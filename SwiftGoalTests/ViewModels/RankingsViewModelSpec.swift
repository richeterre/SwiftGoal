//
//  RankingsViewModelSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 04/01/16.
//  Copyright © 2016 Martin Richter. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
@testable import SwiftGoal

class RankingsViewModelSpec: QuickSpec {
    override func spec() {
        describe("RankingsViewModel") {
            var mockStore: MockStore!
            var rankingsViewModel: RankingsViewModel!

            beforeEach {
                mockStore = MockStore()
                rankingsViewModel = RankingsViewModel(store: mockStore)
            }

            it("has the correct title") {
                expect(rankingsViewModel.title).to(equal("Rankings"))
            }

            it("initially has a only single, empty section") {
                expect(rankingsViewModel.numberOfSections()).to(equal(1))
                expect(rankingsViewModel.numberOfRankingsInSection(0)).to(equal(0))
            }

            context("after becoming active") {
                beforeEach {
                    rankingsViewModel.active.value = true
                }

                it("fetches a list of rankings") {
                    expect(mockStore.didFetchRankings).to(beTrue())
                }

                it("has only a single section") {
                    expect(rankingsViewModel.numberOfSections()).to(equal(1))
                }

                it("has the right number of rankings") {
                    expect(rankingsViewModel.numberOfRankingsInSection(0)).to(equal(4))
                }

                it("displays the right player names") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    let indexPath3 = NSIndexPath(forRow: 2, inSection: 0)
                    let indexPath4 = NSIndexPath(forRow: 3, inSection: 0)
                    expect(rankingsViewModel.playerNameAtIndexPath(indexPath1)).to(equal("A"))
                    expect(rankingsViewModel.playerNameAtIndexPath(indexPath2)).to(equal("C"))
                    expect(rankingsViewModel.playerNameAtIndexPath(indexPath3)).to(equal("D"))
                    expect(rankingsViewModel.playerNameAtIndexPath(indexPath4)).to(equal("B"))
                }

                it("displays the right ratings") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    let indexPath3 = NSIndexPath(forRow: 2, inSection: 0)
                    let indexPath4 = NSIndexPath(forRow: 3, inSection: 0)
                    expect(rankingsViewModel.ratingAtIndexPath(indexPath1)).to(equal("10.00"))
                    expect(rankingsViewModel.ratingAtIndexPath(indexPath2)).to(equal("5.00"))
                    expect(rankingsViewModel.ratingAtIndexPath(indexPath3)).to(equal("5.00"))
                    expect(rankingsViewModel.ratingAtIndexPath(indexPath4)).to(equal("0.00"))
                }
            }

            context("when asked to refresh") {
                it("fetches a list of rankings") {
                    rankingsViewModel.refreshObserver.sendNext(())
                    expect(mockStore.didFetchRankings).to(beTrue())
                }
            }

            context("when becoming active and upon refresh") {
                it("indicates its loading state") {
                    // Aggregate loading states into an array
                    var loadingStates: [Bool] = []
                    rankingsViewModel.isLoading.producer
                        .take(5)
                        .collect()
                        .startWithNext({ values in
                            loadingStates = values
                        })

                    rankingsViewModel.active.value = true
                    rankingsViewModel.refreshObserver.sendNext(())

                    expect(loadingStates).to(equal([false, true, false, true, false]))
                }

                it("notifies subscribers about content changes") {
                    var changeset: Changeset<Ranking>?
                    rankingsViewModel.contentChangesSignal.observeNext { contentChanges in
                        changeset = contentChanges
                    }

                    let expectedInsertions = [
                        NSIndexPath(forRow: 0, inSection: 0),
                        NSIndexPath(forRow: 1, inSection: 0),
                        NSIndexPath(forRow: 2, inSection: 0),
                        NSIndexPath(forRow: 3, inSection: 0)
                    ]

                    rankingsViewModel.active.value = true
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(equal(expectedInsertions))

                    rankingsViewModel.refreshObserver.sendNext(())
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(beEmpty())
                }
            }

            it("raises an alert when rankings cannot be fetched") {
                mockStore.rankings = nil // will cause fetch error

                var didRaiseAlert = false
                rankingsViewModel.alertMessageSignal.observeNext({ alertMessage in
                    didRaiseAlert = true
                })

                rankingsViewModel.active.value = true

                expect(didRaiseAlert).to(beTrue())
            }
        }
    }
}
