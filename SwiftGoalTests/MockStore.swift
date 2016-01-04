//
//  MockStore.swift
//  SwiftGoal
//
//  Created by Martin Richter on 06/08/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa
@testable import SwiftGoal

class MockStore: StoreType {
    // nil is used to cause fetch error
    var players: [Player]?
    var matches: [Match]?
    var rankings: [Ranking]?

    var didFetchMatches = false
    var deletedMatch: Match?

    var didFetchPlayers = false

    var didFetchRankings = false

    init() {
        let player1 = Player(identifier: "player1", name: "C")
        let player2 = Player(identifier: "player2", name: "A")
        let player3 = Player(identifier: "player3", name: "D")
        let player4 = Player(identifier: "player4", name: "B")

        self.players = [player1, player2, player3, player4]
        self.matches = [
            Match(
                identifier: "1",
                homePlayers: [player1, player2],
                awayPlayers: [player3, player4],
                homeGoals: 2,
                awayGoals: 1
            ),
            Match(
                identifier: "2",
                homePlayers: [player1, player4],
                awayPlayers: [player2, player3],
                homeGoals: 0,
                awayGoals: 1
            )
        ]
        self.rankings = [
            Ranking(player: player2, rating: 10),
            Ranking(player: player1, rating: 5),
            Ranking(player: player3, rating: 5),
            Ranking(player: player4, rating: 0)
        ]
    }

    // MARK: Matches

    func fetchMatches() -> SignalProducer<[Match], NSError> {
        didFetchMatches = true
        if let matches = self.matches {
            return SignalProducer(value: matches)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            return SignalProducer(error: error)
        }
    }

    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        return SignalProducer(value: false)
    }

    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        return SignalProducer(value: false)
    }

    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError> {
        deletedMatch = match
        return SignalProducer(value: true)
    }

    // MARK: Players

    func fetchPlayers() -> SignalProducer<[Player], NSError> {
        didFetchPlayers = true
        if let players = self.players {
            return SignalProducer(value: players)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            return SignalProducer(error: error)
        }
    }

    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError> {
        return SignalProducer(value: false)
    }

    // MARK: Rankings

    func fetchRankings() -> SignalProducer<[Ranking], NSError> {
        didFetchRankings = true
        if let rankings = self.rankings {
            return SignalProducer(value: rankings)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            return SignalProducer(error: error)
        }
    }
}
