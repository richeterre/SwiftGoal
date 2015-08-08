//
//  Player.swift
//  SwiftGoal
//
//  Created by Martin Richter on 02/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation
import Argo
import Runes

public struct Player {
    public let identifier: String
    public let name: String

    public init(identifier: String, name: String) {
        self.identifier = identifier
        self.name = name
    }
}

// MARK: Equatable

public func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.identifier == rhs.identifier
}

// MARK: Decodable

extension Player: Decodable {
    static func create(identifier: String)(name: String) -> Player {
        return Player(identifier: identifier, name: name)
    }

    public static func decode(json: JSON) -> Decoded<Player> {
        return Player.create
            <^> json <| "id"
            <*> json <| "name"
    }
}

// MARK: Hashable

extension Player: Hashable {
    public var hashValue: Int {
        return identifier.hashValue
    }
}
