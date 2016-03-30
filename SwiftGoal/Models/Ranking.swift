//
//  Ranking.swift
//  SwiftGoal
//
//  Created by Martin Richter on 24/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Argo
import Curry

struct Ranking {
    let player: Player
    let rating: Float

    static func contentMatches(lhs: Ranking, _ rhs: Ranking) -> Bool {
        return Player.contentMatches(lhs.player, rhs.player)
            && lhs.rating == rhs.rating
    }

    static func contentMatches(lhs: [Ranking], _ rhs: [Ranking]) -> Bool {
        // Make sure arrays have same size
        guard lhs.count == rhs.count else { return false }

        // Look at pairs of rankings
        let hasMismatch = zip(lhs, rhs)
            .map { contentMatches($0, $1) } // Apply content matcher to each
            .contains(false) // Check for mismatches
        return !hasMismatch
    }
}

// MARK: Equatable

func ==(lhs: Ranking, rhs: Ranking) -> Bool {
    return lhs.player == rhs.player
}

// MARK: Decodable

extension Ranking: Decodable {
    static func decode(json: JSON) -> Decoded<Ranking> {
        return curry(Ranking.init)
            <^> json <| "player"
            <*> json <| "rating"
    }
}

// MARK: Hashable

extension Ranking: Hashable {
    var hashValue: Int {
        return player.identifier.hashValue ^ rating.hashValue
    }
}
