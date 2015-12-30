//
//  StoreType.swift
//  SwiftGoal
//
//  Created by Martin Richter on 30/12/15.
//  Copyright © 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

struct MatchParameters {
    let homePlayers: Set<Player>
    let awayPlayers: Set<Player>
    let homeGoals: Int
    let awayGoals: Int
}

protocol StoreType {
    // Matches
    func fetchMatches() -> SignalProducer<[Match], NSError>
    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError>
    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError>
    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError>

    // Players
    func fetchPlayers() -> SignalProducer<[Player], NSError>
    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError>

    // Rankings
    func fetchRankings() -> SignalProducer<[Ranking], NSError>
}
