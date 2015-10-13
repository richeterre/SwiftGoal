//
//  Ranking.swift
//  SwiftGoal
//
//  Created by Martin Richter on 24/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation
import Argo

struct Ranking {
    let player: Player
    let rating: Float
}

// MARK: Equatable

func ==(lhs: Ranking, rhs: Ranking) -> Bool {
    return lhs.player == rhs.player && lhs.rating == rhs.rating
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
