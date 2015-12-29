//
//  Ranking.swift
//  SwiftGoal
//
//  Created by Martin Richter on 24/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Argo

struct Ranking {
    let player: Player
    let rating: Float

    static func contentMatches(lhs: Ranking, _ rhs: Ranking) -> Bool {
        return Player.contentMatches(lhs.player, rhs.player)
            && lhs.rating == rhs.rating
    }
}

// MARK: Equatable

func ==(lhs: Ranking, rhs: Ranking) -> Bool {
    return lhs.player == rhs.player
}

// MARK: Decodable

extension Ranking: Decodable {
    static func create(player: Player)(rating: Float) -> Ranking {
        return Ranking(player: player, rating: rating)
    }

    static func decode(json: JSON) -> Decoded<Ranking> {
        return Ranking.create
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
