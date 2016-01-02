//
//  RankingEngineSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 02/01/16.
//  Copyright © 2016 Martin Richter. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftGoal

class RankingEngineSpec: QuickSpec {
    override func spec() {
        describe("A RankingEngine") {
            describe("for empty input") {
                it("returns an empty array") {
                    let rankingEngine = RankingEngine()
                    let rankings = rankingEngine.rankingsForPlayers([], fromMatches: [])
                    expect(rankings).to(equal([]))
                }
            }
        }
    }
}
