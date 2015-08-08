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
import SwiftGoal

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

            it("initially has a single empty section") {
                expect(matchesViewModel.numberOfSections()).to(equal(1))
                expect(matchesViewModel.numberOfMatchesInSection(0)).to(equal(0))
            }

            context("after becoming active") {
                beforeEach {
                    matchesViewModel.active.put(true)
                }

                it("should fetch a list of matches") {
                    expect(mockStore.didFetchMatches).to(beTrue())
                }

                it("should only have a single section") {
                    expect(matchesViewModel.numberOfSections()).to(equal(1))
                }

                it("should have the right number of matches") {
                    expect(matchesViewModel.numberOfMatchesInSection(0)).to(equal(2))
                }

                it("should return the home players in alphabetical order") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    expect(matchesViewModel.homePlayersAtIndexPath(indexPath1)).to(equal("C, A"))
                    expect(matchesViewModel.homePlayersAtIndexPath(indexPath2)).to(equal("C, B"))
                }

                it("should return the away players in alphabetical order") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    expect(matchesViewModel.awayPlayersAtIndexPath(indexPath1)).to(equal("D, B"))
                    expect(matchesViewModel.awayPlayersAtIndexPath(indexPath2)).to(equal("A, D"))
                }

                it("should display the right match results") {
                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)
                    expect(matchesViewModel.resultAtIndexPath(indexPath1)).to(equal("2 : 1"))
                    expect(matchesViewModel.resultAtIndexPath(indexPath2)).to(equal("0 : 1"))
                }
            }

            context("when asked to refresh") {
                it("should fetch a list of matches") {
                    sendNext(matchesViewModel.refreshSink, ())
                    expect(mockStore.didFetchMatches).to(beTrue())
                }
            }

            context("when becoming active and upon refresh") {
                it("should notify subscribers about content changes") {
                    var changeset: Changeset?
                    matchesViewModel.contentChangesSignal.observe { contentChanges in
                        changeset = contentChanges
                    }

                    let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
                    let indexPath2 = NSIndexPath(forRow: 1, inSection: 0)

                    matchesViewModel.active.put(true)
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(equal([indexPath1, indexPath2]))

                    sendNext(matchesViewModel.refreshSink, ())
                    expect(changeset?.deletions).to(beEmpty())
                    expect(changeset?.insertions).to(beEmpty())
                }
            }

            it("should delete the correct match when asked to") {
                let match = mockStore.matches[1]
                let indexPath = NSIndexPath(forRow: 1, inSection: 0)

                var deletedSuccessfully = false

                matchesViewModel.active.put(true)
                matchesViewModel.deleteAction.apply(indexPath).start(next: { success in
                    deletedSuccessfully = success
                })

                expect(mockStore.deletedMatch).to(equal(match))
                expect(deletedSuccessfully).to(beTrue())
            }
        }
    }
}
