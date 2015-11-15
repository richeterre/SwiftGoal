//
//  MatchSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 15/11/15.
//  Copyright © 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftGoal

class MatchSpec: QuickSpec {

    override func spec() {
        describe("A Match") {
            it("is equal to another Match iff (if and only if) their identifiers match") {
                let m1 = Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
                let m2 = Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
                let m3 = Match(identifier: "b", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
                expect(m1).to(equal(m2))
                expect(m1).notTo(equal(m3))
            }

            context("when compared by content to another Match") {

                let basePlayers = [
                    Player(identifier: "p1", name: "John"),
                    Player(identifier: "p2", name: "Mary")
                ]

                // Different amount of players (some player missing)
                let differentCountPlayers = [
                    Player(identifier: "p1", name: "John")
                ]

                // Different content of players
                let differentContentPlayers = [
                    Player(identifier: "p1", name: "Jack"),
                    Player(identifier: "p2", name: "Mary")
                ]

                // Different identity of players who have the same content
                let differentIdentityPlayers = [
                    Player(identifier: "p3", name: "John"),
                    Player(identifier: "p4", name: "Mary")
                ]

                it("does not match when the identifiers differ") {
                    let m1 = Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
                    let m2 = Match(identifier: "b", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
                    expect(Match.contentMatches(m1, m2)).to(beFalse())
                }

                it("does not match when the home players differ") {
                    let m1 = Match(identifier: "a", homePlayers: basePlayers, awayPlayers: [], homeGoals: 0, awayGoals: 0)
                    let m2 = Match(identifier: "a", homePlayers: differentCountPlayers, awayPlayers: [], homeGoals: 0, awayGoals: 0)
                    let m3 = Match(identifier: "a", homePlayers: differentContentPlayers, awayPlayers: [], homeGoals: 0, awayGoals: 0)
                    let m4 = Match(identifier: "a", homePlayers: differentIdentityPlayers, awayPlayers: [], homeGoals: 0, awayGoals: 0)

                    expect(Match.contentMatches(m1, m2)).to(beFalse())
                    expect(Match.contentMatches(m1, m3)).to(beFalse())
                    expect(Match.contentMatches(m1, m4)).to(beFalse())
                }

                it("does not match when the away players differ") {
                    let m1 = Match(identifier: "a", homePlayers: [], awayPlayers: basePlayers, homeGoals: 0, awayGoals: 0)
                    let m2 = Match(identifier: "a", homePlayers: [], awayPlayers: differentCountPlayers, homeGoals: 0, awayGoals: 0)
                    let m3 = Match(identifier: "a", homePlayers: [], awayPlayers: differentContentPlayers, homeGoals: 0, awayGoals: 0)
                    let m4 = Match(identifier: "a", homePlayers: [], awayPlayers: differentIdentityPlayers, homeGoals: 0, awayGoals: 0)

                    expect(Match.contentMatches(m1, m2)).to(beFalse())
                    expect(Match.contentMatches(m1, m3)).to(beFalse())
                    expect(Match.contentMatches(m1, m4)).to(beFalse())
                }

                it("does not match when the home goals differ") {
                    let m1 = Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
                    let m2 = Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 1, awayGoals: 0)

                    expect(Match.contentMatches(m1, m2)).to(beFalse())
                }

                it("does not match when the away goals differ") {
                    let m1 = Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
                    let m2 = Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 1)

                    expect(Match.contentMatches(m1, m2)).to(beFalse())
                }

                it("matches when all properties match") {
                    let m1 = Match(identifier: "a", homePlayers: basePlayers, awayPlayers: basePlayers, homeGoals: 0, awayGoals: 0)
                    let m2 = Match(identifier: "a", homePlayers: basePlayers, awayPlayers: basePlayers, homeGoals: 0, awayGoals: 0)

                    expect(Match.contentMatches(m1, m2)).to(beTrue())
                }
            }
        }
    }
}
