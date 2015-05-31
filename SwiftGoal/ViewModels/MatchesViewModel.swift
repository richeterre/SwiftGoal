//
//  MatchesViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation
import ReactiveCocoa

class MatchesViewModel: NSObject {

    // Inputs
    let active = MutableProperty(false)

    // Outputs
    let title: String
    let (updatedContentSignal, updatedContentSink) = Signal<Bool, NoError>.pipe()

    private let store: Store
    private var matches: [Match]

    // MARK: - Lifecycle

    init(store: Store) {
        self.title = "Matches"
        self.store = store
        self.matches = []

        super.init()

        // Define this separately to make Swift compiler happy
        let activeToMatchesSignal: SignalProducer<Bool, NoError> -> SignalProducer<[Match], NoError> = flatMap(.Latest) {
            active in store.fetchMatches()
        }

        active.producer
            |> activeToMatchesSignal
            |> start(next: { [weak self] matches in
                self?.matches = matches
                if let sink = self?.updatedContentSink {
                    sendNext(sink, true)
                }
        })
    }

    // MARK: - Data Source

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfMatchesInSection(section: Int) -> Int {
        return count(matches)
    }

    func matchAtRow(row: Int, inSection: Int) -> String {
        return matches[row].title
    }
}
