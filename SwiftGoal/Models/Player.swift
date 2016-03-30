//
//  Player.swift
//  SwiftGoal
//
//  Created by Martin Richter on 02/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Argo
import Curry

struct Player {
    let identifier: String
    let name: String

    static private let identifierKey = "id"
    static private let nameKey = "name"

    init(identifier: String, name: String) {
        self.identifier = identifier
        self.name = name
    }

    static func contentMatches(lhs: Player, _ rhs: Player) -> Bool {
        return lhs.identifier == rhs.identifier
            && lhs.name == rhs.name
    }

    static func contentMatches(lhs: [Player], _ rhs: [Player]) -> Bool {
        if lhs.count != rhs.count { return false }

        for (index, player) in lhs.enumerate() {
            if !contentMatches(rhs[index], player) {
                return false
            }
        }

        return true
    }
}

// MARK: Equatable

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.identifier == rhs.identifier
}

// MARK: Hashable

extension Player: Hashable {
    var hashValue: Int {
        return identifier.hashValue
    }
}

// MARK: Decodable

extension Player: Decodable {
    static func decode(json: JSON) -> Decoded<Player> {
        return curry(Player.init)
            <^> json <| identifierKey
            <*> json <| nameKey
    }
}

// MARK: Encodable

extension Player: Encodable {
    func encode() -> [String: AnyObject] {
        return [
            Player.identifierKey: identifier,
            Player.nameKey: name
        ]
    }
}
