//
//  Store.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation
import ReactiveCocoa

class Store: NSObject {

    private let fakeDelay: NSTimeInterval = 1

    private let matches = [
        Match(title: "First"),
        Match(title: "Second")
    ]

    // MARK: - Matches

    func fetchMatches() -> SignalProducer<[Match], NoError> {
        return SignalProducer(value: matches)
            |> delay(fakeDelay, onScheduler: QueueScheduler.mainQueueScheduler)
    }
}
