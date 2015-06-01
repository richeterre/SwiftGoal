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
    let (contentChangesSignal, contentChangesSink) = Signal<Changeset, NoError>.pipe()

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
            |> combinePrevious([]) // Preserve history of previous match array to calculate changeset
            |> start(next: { [weak self] (oldMatches, newMatches) in
                self?.matches = newMatches
                if let sink = self?.contentChangesSink {
                    let changeset = Changeset(oldItems: oldMatches, newItems: newMatches)
                    sendNext(sink, changeset)
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
