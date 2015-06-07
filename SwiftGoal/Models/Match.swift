//
//  Match.swift
//  SwiftGoal
//
//  Created by Martin Richter on 11/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Argo
import Runes

struct Match {
    let identifier: String
    let homeGoals: Int
    let awayGoals: Int
}

// MARK: Equatable

extension Match: Equatable {}

func ==(lhs: Match, rhs: Match) -> Bool {
    return lhs.identifier == rhs.identifier
}

// MARK: Decodable

extension Match: Decodable {
    static func create(identifier: String)(homeGoals: Int)(awayGoals: Int) -> Match {
        return Match(
            identifier: identifier,
            homeGoals: homeGoals,
            awayGoals: awayGoals
        )
    }

    static func decode(j: JSON) -> Decoded<Match> {
        return Match.create
            <^> j <| "id"
            <*> j <| "home_goals"
            <*> j <| "away_goals"
    }
}
