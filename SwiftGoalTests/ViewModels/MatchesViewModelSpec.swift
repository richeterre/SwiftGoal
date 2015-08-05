//
//  MatchesViewModelSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 06/08/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
import SwiftGoal

class MatchesViewModelSpec: QuickSpec {
    override func spec() {
        describe("A MatchesViewModel") {
            context("after becoming active") {
                it("should fetch a list of matches") {
                    let mockStore = MockStore()
                    let matchesViewModel = MatchesViewModel(store: mockStore)

                    matchesViewModel.active.put(true)

                    expect(mockStore.didFetchMatches).to(beTrue())
                    expect(matchesViewModel.numberOfMatchesInSection(0)).to(equal(2))
                }
            }
        }
    }
}
