//
//  Match.swift
//  SwiftGoal
//
//  Created by Martin Richter on 11/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Argo

public struct Match {
    let identifier: String
    let homePlayers: [Player]
    let awayPlayers: [Player]
    let homeGoals: Int
    let awayGoals: Int

    public init(identifier: String, homePlayers: [Player], awayPlayers: [Player], homeGoals: Int, awayGoals: Int) {
        self.identifier = identifier
        self.homePlayers = homePlayers
        self.awayPlayers = awayPlayers
        self.homeGoals = homeGoals
        self.awayGoals = awayGoals
    }
}

// MARK: Equatable

extension Match: Equatable {}

public func ==(lhs: Match, rhs: Match) -> Bool {
    return lhs.identifier == rhs.identifier
        && lhs.homePlayers == rhs.homePlayers
        && lhs.awayPlayers == rhs.awayPlayers
        && lhs.homeGoals == rhs.homeGoals
        && lhs.awayGoals == rhs.awayGoals
}

// MARK: Decodable

extension Match: Decodable {
    static func create(identifier: String)(homePlayers: [Player])(awayPlayers: [Player])(homeGoals: Int)(awayGoals: Int) -> Match {
        return Match(
            identifier: identifier,
            homePlayers: homePlayers,
            awayPlayers: awayPlayers,
            homeGoals: homeGoals,
            awayGoals: awayGoals
        )
    }

    public static func decode(json: JSON) -> Decoded<Match> {
        return Match.create
            <^> json <| "id"
            <*> json <|| "home_players"
            <*> json <|| "away_players"
            <*> json <| "home_goals"
            <*> json <| "away_goals"
    }
}
