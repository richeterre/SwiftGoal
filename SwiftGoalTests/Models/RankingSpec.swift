//
//  RankingSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 15/11/15.
//  Copyright © 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftGoal

class RankingSpec: QuickSpec {

    override func spec() {
        describe("A Ranking") {
            it("is not equal to another Ranking if its players are not equal") {
                let player1 = Player(identifier: "p1", name: "John")
                let player2 = Player(identifier: "p2", name: "Mary")

                let r1 = Ranking(player: player1, rating: 0)
                let r2 = Ranking(player: player2, rating: 0)

                expect(r1).notTo(equal(r2))
            }

            it("is equal to another Ranking if its players are equal, no matter the rest") {
                let player1 = Player(identifier: "p1", name: "John")
                let player2 = Player(identifier: "p1", name: "Jack")

                let r1 = Ranking(player: player1, rating: 0)
                let r2 = Ranking(player: player2, rating: 1)

                expect(r1).to(equal(r2))
            }

            context("when compared by content to another Ranking") {

                it("does not match when the players differ in content") {
                    let player1 = Player(identifier: "p1", name: "John")
                    let player2 = Player(identifier: "p1", name: "Jack")

                    let r1 = Ranking(player: player1, rating: 0)
                    let r2 = Ranking(player: player2, rating: 0)

                    expect(Ranking.contentMatches(r1, r2)).to(beFalse())
                }

                it("does not match when the ratings differ") {
                    let player = Player(identifier: "p1", name: "John")
                    let r1 = Ranking(player: player, rating: 0)
                    let r2 = Ranking(player: player, rating: 1)

                    expect(Ranking.contentMatches(r1, r2)).to(beFalse())
                }

                it("matches when all properties match") {
                    let player = Player(identifier: "p1", name: "John")
                    let r1 = Ranking(player: player, rating: 0)
                    let r2 = Ranking(player: player, rating: 0)

                    expect(Ranking.contentMatches(r1, r2)).to(beTrue())
                }
            }

            context("when compared in bulk to another Ranking array") {
                let player = Player(identifier: "p1", name: "John")
                let r1 = Ranking(player: player, rating: 0)
                let r2 = Ranking(player: player, rating: 1)

                it("does not match when the array counts differ") {
                    let array1 = [r1, r1]
                    let array2 = [r1]

                    expect(Ranking.contentMatches(array1, array2)).to(beFalse())
                }

                it("does not match when the array order differs") {
                    let array1 = [r1, r2]
                    let array2 = [r2, r1]

                    expect(Ranking.contentMatches(array1, array2)).to(beFalse())
                }

                it("does not match when any item differs") {
                    let array1 = [r1, r1]
                    let array2 = [r1, r2]

                    expect(Ranking.contentMatches(array1, array2)).to(beFalse())
                }

                it("matches when all items match") {
                    let array1 = [r1, r2]
                    let array2 = [r1, r2]

                    expect(Ranking.contentMatches(array1, array2)).to(beTrue())
                }
            }
        }
    }
}
