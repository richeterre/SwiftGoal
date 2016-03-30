//
//  Match.swift
//  SwiftGoal
//
//  Created by Martin Richter on 11/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Argo
import Curry

struct Match {
    let identifier: String
    let homePlayers: [Player]
    let awayPlayers: [Player]
    let homeGoals: Int
    let awayGoals: Int

    static private let identifierKey = "id"
    static private let homePlayersKey = "home_players"
    static private let awayPlayersKey = "away_players"
    static private let homeGoalsKey = "home_goals"
    static private let awayGoalsKey = "away_goals"

    init(identifier: String, homePlayers: [Player], awayPlayers: [Player], homeGoals: Int, awayGoals: Int) {
        self.identifier = identifier
        self.homePlayers = homePlayers
        self.awayPlayers = awayPlayers
        self.homeGoals = homeGoals
        self.awayGoals = awayGoals
    }

    // TODO: Decide if content matching should include identifier or not
    static func contentMatches(lhs: Match, _ rhs: Match) -> Bool {
        return lhs.identifier == rhs.identifier
            && Player.contentMatches(lhs.homePlayers, rhs.homePlayers)
            && Player.contentMatches(lhs.awayPlayers, rhs.awayPlayers)
            && lhs.homeGoals == rhs.homeGoals
            && lhs.awayGoals == rhs.awayGoals
    }
}

// MARK: Equatable

extension Match: Equatable {}

func ==(lhs: Match, rhs: Match) -> Bool {
    return lhs.identifier == rhs.identifier
}

// MARK: Decodable

extension Match: Decodable {
    static func decode(json: JSON) -> Decoded<Match> {
        return curry(Match.init)
            <^> json <| identifierKey
            <*> json <|| homePlayersKey
            <*> json <|| awayPlayersKey
            <*> json <| homeGoalsKey
            <*> json <| awayGoalsKey
    }
}

// MARK: Encodable

extension Match: Encodable {
    func encode() -> [String: AnyObject] {
        return [
            Match.identifierKey: identifier,
            Match.homePlayersKey: homePlayers.map { $0.encode() },
            Match.awayPlayersKey: awayPlayers.map { $0.encode() },
            Match.homeGoalsKey: homeGoals,
            Match.awayGoalsKey: awayGoals
        ]
    }
}
