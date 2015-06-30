//
//  ManagePlayersViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 30/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

class ManagePlayersViewModel {

    // Inputs
    let active = MutableProperty(false)

    // Outputs
    let title: String
    let (contentChangesSignal, contentChangesSink) = Signal<Changeset, NoError>.pipe()

    private let store: Store
    private var players: [Player]

    // MARK: Lifecycle

    init(store: Store) {
        self.title = "Players"
        self.store = store
        self.players = []

        active.producer
            |> filter { $0 }
            |> flatMap(.Latest, { _ in return store.fetchPlayers() })
            |> combinePrevious([]) // Preserve history to calculate changeset
            |> start(next: { [weak self] (oldPlayers, newPlayers) in
                self?.players = newPlayers
                if let sink = self?.contentChangesSink {
                    let changeset = Changeset(oldItems: oldPlayers, newItems: newPlayers)
                    sendNext(sink, changeset)
                }
            })
    }

    // MARK: Data Source

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfPlayersInSection(section: Int) -> Int {
        return count(players)
    }

    func playerAtRow(row: Int, inSection section: Int) -> String {
        return players[row].name
    }
}