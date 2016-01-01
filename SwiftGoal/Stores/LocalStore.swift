//
//  LocalStore.swift
//  SwiftGoal
//
//  Created by Martin Richter on 31/12/15.
//  Copyright © 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

class LocalStore: StoreType {

    private var matches = [Match]()
    private var players = [Player]()

    // MARK: Matches

    func fetchMatches() -> SignalProducer<[Match], NSError> {
        return SignalProducer(value: matches)
    }

    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        let identifier = randomIdentifier()
        let match = matchFromParameters(parameters, withIdentifier: identifier)
        matches.append(match)

        return SignalProducer(value: true)
    }

    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        if let oldMatchIndex = matches.indexOf(match) {
            let newMatch = matchFromParameters(parameters, withIdentifier: match.identifier)
            matches.removeAtIndex(oldMatchIndex)
            matches.insert(newMatch, atIndex: oldMatchIndex)
            return SignalProducer(value: true)
        } else {
            return SignalProducer(value: false)
        }
    }

    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError> {
        if let index = matches.indexOf(match) {
            matches.removeAtIndex(index)
            return SignalProducer(value: true)
        } else {
            return SignalProducer(value: false)
        }
    }

    // MARK: Players

    func fetchPlayers() -> SignalProducer<[Player], NSError> {
        return SignalProducer(value: players)
    }

    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError> {
        let player = Player(identifier: randomIdentifier(), name: name)
        players.append(player)
        return SignalProducer(value: true)
    }

    // MARK: Rankings

    func fetchRankings() -> SignalProducer<[Ranking], NSError> {
        let rankings = players.map { player in
            return Ranking(player: player, rating: 0)
        }
        return SignalProducer(value: rankings)
    }

    // MARK: Private Helpers

    private func randomIdentifier() -> String {
        return NSUUID().UUIDString
    }

    private func matchFromParameters(parameters: MatchParameters, withIdentifier identifier: String) -> Match {
        let sortByName: (Player, Player) -> Bool = { players in
            players.0.name < players.1.name
        }

        return Match(
            identifier: identifier,
            homePlayers: parameters.homePlayers.sort(sortByName),
            awayPlayers: parameters.awayPlayers.sort(sortByName),
            homeGoals: parameters.homeGoals,
            awayGoals: parameters.awayGoals
        )
    }
}
