//
//  MockStore.swift
//  SwiftGoal
//
//  Created by Martin Richter on 06/08/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SwiftGoal

class MockStore: Store {
    let matches: [Match] = [
        Match(identifier: "a", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0),
        Match(identifier: "b", homePlayers: [], awayPlayers: [], homeGoals: 0, awayGoals: 0)
    ]

    var didFetchMatches = false

    init() {
        super.init(baseURL: NSURL(string: "")!)
    }

    override func fetchMatches() -> SignalProducer<[Match], NSError> {
        didFetchMatches = true
        return SignalProducer(value: matches)
    }
}
