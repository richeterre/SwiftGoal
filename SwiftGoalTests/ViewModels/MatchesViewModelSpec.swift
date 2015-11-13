//
//  MatchesViewModelSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 06/08/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
@testable import SwiftGoal

class MatchesViewModelSpec: QuickSpec {
    override func spec() {
        describe("MatchesViewModel") {
            var mockStore: MockStore!
            var matchesViewModel: MatchesViewModel!

            beforeEach {
                mockStore = MockStore()
                matchesViewModel = MatchesViewModel(store: mockStore)
            }

            it("has the correct title") {
                expect(matchesViewModel.title).to(equal("Matches"))
            }

            it("initially has a only single, empty section") {
                expect(matchesViewModel.numberOfSections()).to(equal(1))
                expect(matchesViewModel.numberOfMatchesInSection(0)).to(equal(0))
            }

            context("after becoming active") {
                beforeEach {
                    matchesViewModel.active.value = true
                }

                it("fetches a list of matches") {
                    expect(mockStore.didFetchMatches).to(beTrue())
                }

                it("has only a single section") {
                    expect(matchesViewModel.numberOfSections()).to(equal(1))
                }

                it("has the right number of matches") {
                    expect(matchesViewModel.numberOfMatchesInSection(0)).to(equal(2))
                }

                it("returns the home players in alphabetical order") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    expect(matchesViewModel.homePlayersAtIndexPath(indexPath1)).to(equal("C, A"))
                    expect(matchesViewModel.homePlayersAtIndexPath(indexPath2)).to(equal("C, B"))
                }

                it("returns the away players in alphabetical order") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    expect(matchesViewModel.awayPlayersAtIndexPath(indexPath1)).to(equal("D, B"))
                    expect(matchesViewModel.awayPlayersAtIndexPath(indexPath2)).to(equal("A, D"))
                }

                it("displays the right match results") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    expect(matchesViewModel.resultAtIndexPath(indexPath1)).to(equal("2 : 1"))
                    expect(matchesViewModel.resultAtIndexPath(indexPath2)).to(equal("0 : 1"))
                }
            }

            context("when asked to refresh") {
                it("fetches a list of matches") {
                    matchesViewModel.refreshObserver.sendNext(true)
                    expect(mockStore.didFetchMatches).to(beTrue())
                }
            }

            context("when becoming active and upon refresh") {
                it("indicates its loading state") {
                    // Aggregate loading states into an array
                    var loadingStates: [Bool] = []
                    matchesViewModel.isLoading.producer
                        .take(5)
                        .collect()
                        .startWithNext({ values in
                            loadingStates = values
                        })

                    matchesViewModel.active.value = true
                    matchesViewModel.refreshObserver.sendNext(true)

                    expect(loadingStates).to(equal([false, true, false, true, false]))
                }

                it("notifies subscribers about content changes") {
                    var changeset: Changeset?
                    matchesViewModel.contentChangesSignal.observeNext { contentChanges in
                        changeset = contentChanges
                    }

                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)

                    matchesViewModel.active.value = true
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(equal([indexPath1, indexPath2]))

                    matchesViewModel.refreshObserver.sendNext(true)
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(beEmpty())
                }
            }

            it("raises an alert when matches cannot be fetched") {
                mockStore.matches = nil // will cause fetch error

                var didRaiseAlert = false
                matchesViewModel.alertMessageSignal.observeNext({ alertMessage in
                    didRaiseAlert = true
                })

                matchesViewModel.active.value = true

                expect(didRaiseAlert).to(beTrue())
            }
            
            it("cancel network requests when the associated view becomes inactive") {
                matchesViewModel.active.value = true
                matchesViewModel.active.value = false
                
                expect(mockStore.numFetched).to(equal(1))
            }

            it("deletes the correct match when asked to") {
                let match = mockStore.matches![1]
                let indexPath = NSIndexPath(forRow: 1, inSection: 0)

                var deletedSuccessfully = false

                matchesViewModel.active.value = true
                matchesViewModel.deleteAction.apply(indexPath).startWithNext({ success in
                    deletedSuccessfully = success
                })

                expect(mockStore.deletedMatch).to(equal(match))
                expect(deletedSuccessfully).to(beTrue())
            }

            it("provides a view model for creating a new match") {
                let createMatchViewModel = matchesViewModel.editViewModelForNewMatch()
                expect(createMatchViewModel.title).to(equal("New Match"))
            }

            it("provides the correct view model for editing an existing match") {
                matchesViewModel.active.value = true

                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                let editMatchViewModel = matchesViewModel.editViewModelForMatchAtIndexPath(indexPath)
                expect(editMatchViewModel.title).to(equal("Edit Match"))
                expect(editMatchViewModel.formattedHomeGoals.value).to(equal("2"))
                expect(editMatchViewModel.formattedAwayGoals.value).to(equal("1"))
            }
        }
    }
}
