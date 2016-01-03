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
            let rankingEngine = RankingEngine()

            describe("for empty input") {
                it("returns an empty array") {
                    let rankings = rankingEngine.rankingsForPlayers([], fromMatches: [])
                    expect(rankings).to(equal([]))
                }
            }

            describe("for one player") {
                let p1 = Player(identifier: "a", name: "A")

                it("gives a zero rating when the player has no matches") {
                    let rankings = rankingEngine.rankingsForPlayers([p1], fromMatches: [])

                    let expectedRankings = [
                        Ranking(player: p1, rating: 0)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }

                it("returns only that player's ranking") {
                    let p2 = Player(identifier: "b", name: "B")
                    let match = Match(identifier: "1", homePlayers: [p1], awayPlayers: [p2], homeGoals: 1, awayGoals: 0)
                    let rankings = rankingEngine.rankingsForPlayers([p1], fromMatches: [match])

                    let expectedRankings = [
                        Ranking(player: p1, rating: 10)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }
            }

            describe("for two players") {
                let p1 = Player(identifier: "a", name: "A")
                let p2 = Player(identifier: "b", name: "B")

                it("provides correct ratings for a home win") {
                    let match = Match(identifier: "1", homePlayers: [p1], awayPlayers: [p2], homeGoals: 1, awayGoals: 0)
                    let rankings = rankingEngine.rankingsForPlayers([p1, p2], fromMatches: [match])

                    let expectedRankings = [
                        Ranking(player: p1, rating: 10),
                        Ranking(player: p2, rating: 0)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }

                it("provides correct ratings for a tie") {
                    let match = Match(identifier: "1", homePlayers: [p1], awayPlayers: [p2], homeGoals: 1, awayGoals: 1)
                    let rankings = rankingEngine.rankingsForPlayers([p1, p2], fromMatches: [match])

                    let expectedRankings = [
                        Ranking(player: p1, rating: 10/3),
                        Ranking(player: p2, rating: 10/3)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }

                it("provides correct ratings for an away win") {
                    let match = Match(identifier: "1", homePlayers: [p1], awayPlayers: [p2], homeGoals: 0, awayGoals: 1)
                    let rankings = rankingEngine.rankingsForPlayers([p1, p2], fromMatches: [match])

                    let expectedRankings = [
                        Ranking(player: p2, rating: 10),
                        Ranking(player: p1, rating: 0)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }

                it("provides correct ratings for a mixed set of matches") {
                    let m1 = Match(identifier: "1", homePlayers: [p1], awayPlayers: [p2], homeGoals: 1, awayGoals: 0)
                    let m2 = Match(identifier: "2", homePlayers: [p1], awayPlayers: [p2], homeGoals: 0, awayGoals: 1)
                    let m3 = Match(identifier: "3", homePlayers: [p1], awayPlayers: [p2], homeGoals: 0, awayGoals: 0)
                    let m4 = Match(identifier: "4", homePlayers: [p2], awayPlayers: [p1], homeGoals: 1, awayGoals: 0)
                    let m5 = Match(identifier: "5", homePlayers: [p2], awayPlayers: [p1], homeGoals: 0, awayGoals: 1)

                    let rankings = rankingEngine.rankingsForPlayers([p1, p2], fromMatches: [m1, m2, m3, m4, m5])

                    let expectedRankings = [
                        Ranking(player: p1, rating: 10 * 7/15),
                        Ranking(player: p2, rating: 10 * 7/15)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }
            }

            describe("for more than two players") {
                let p1 = Player(identifier: "a", name: "A")
                let p2 = Player(identifier: "b", name: "B")
                let p3 = Player(identifier: "c", name: "C")

                it("take only a player's own matches into account for their rating") {
                    let matches = [
                        Match(identifier: "1", homePlayers: [p1], awayPlayers: [p2], homeGoals: 1, awayGoals: 0),
                        Match(identifier: "2", homePlayers: [p2], awayPlayers: [p1], homeGoals: 1, awayGoals: 0),
                        Match(identifier: "3", homePlayers: [p1], awayPlayers: [p3], homeGoals: 1, awayGoals: 0),
                        Match(identifier: "4", homePlayers: [p3], awayPlayers: [p1], homeGoals: 1, awayGoals: 0),
                        Match(identifier: "5", homePlayers: [p2], awayPlayers: [p3], homeGoals: 1, awayGoals: 0),
                        Match(identifier: "6", homePlayers: [p3], awayPlayers: [p2], homeGoals: 1, awayGoals: 0)
                    ]
                    let rankings = rankingEngine.rankingsForPlayers([p1, p2, p3], fromMatches: matches)

                    let expectedRankings = [
                        Ranking(player: p1, rating: 5),
                        Ranking(player: p2, rating: 5),
                        Ranking(player: p3, rating: 5)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }

                it("orders the rankings by descending rating") {
                    let m1 = Match(identifier: "1", homePlayers: [p1], awayPlayers: [p2], homeGoals: 0, awayGoals: 1)
                    let m2 = Match(identifier: "2", homePlayers: [p2], awayPlayers: [p3], homeGoals: 0, awayGoals: 0)
                    let rankings = rankingEngine.rankingsForPlayers([p1, p2, p3], fromMatches: [m1, m2])

                    let expectedRankings = [
                        Ranking(player: p2, rating: 10 * 2/3),
                        Ranking(player: p3, rating: 10/3),
                        Ranking(player: p1, rating: 0)
                    ]

                    expect(Ranking.contentMatches(rankings, expectedRankings)).to(beTrue())
                }
            }
        }
    }
}
