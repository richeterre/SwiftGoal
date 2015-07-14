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
    let playerName = MutableProperty("")
    let refreshSink: SinkOf<Event<Void, NoError>>

    // Outputs
    let title: String
    let contentChangesSignal: Signal<Changeset, NoError>
    let isLoadingSignal: Signal<Bool, NoError>
    let selectedPlayers: MutableProperty<Set<Player>>
    let inputIsValid = MutableProperty(false)

    // Actions
    lazy var saveAction: Action<Void, Bool, NoError> = { [unowned self] in
        return Action(enabledIf: self.inputIsValid, { _ in
            return self.store.createPlayer(name: self.playerName.value)
        })
    }()

    private let store: Store
    private let contentChangesSink: SinkOf<Event<Changeset, NoError>>
    private let isLoadingSink: SinkOf<Event<Bool, NoError>>
    private let disabledPlayers: Set<Player>

    private var players: [Player]

    // MARK: Lifecycle

    init(store: Store, initialPlayers: Set<Player>, disabledPlayers: Set<Player>) {
        self.title = "Players"
        self.store = store
        self.players = []
        self.selectedPlayers = MutableProperty(initialPlayers)
        self.disabledPlayers = disabledPlayers

        let (refreshSignal, refreshSink) = SignalProducer<Void, NoError>.buffer()
        self.refreshSink = refreshSink

        let (contentChangesSignal, contentChangesSink) = Signal<Changeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesSink = contentChangesSink

        let (isLoadingSignal, isLoadingSink) = Signal<Bool, NoError>.pipe()
        self.isLoadingSignal = isLoadingSignal
        self.isLoadingSink = isLoadingSink

        active.producer
            |> filter { $0 }
            |> map { _ in () }
            |> start(refreshSink)

        saveAction.values
            |> filter { $0 }
            |> map { _ in () }
            |> observe(refreshSink)

        refreshSignal
            |> on(next: { _ in sendNext(isLoadingSink, true) })
            |> flatMap(.Latest, { _ in return store.fetchPlayers() })
            |> on(next: { _ in sendNext(isLoadingSink, false) })
            |> combinePrevious([]) // Preserve history to calculate changeset
            |> start(next: { [weak self] (oldPlayers, newPlayers) in
                self?.players = newPlayers
                if let sink = self?.contentChangesSink {
                    let changeset = Changeset(oldItems: oldPlayers, newItems: newPlayers)
                    sendNext(sink, changeset)
                }
            })

        inputIsValid <~ playerName.producer |> map { count($0) > 0 }
    }

    // MARK: Data Source

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfPlayersInSection(section: Int) -> Int {
        return count(players)
    }

    func playerNameAtRow(row: Int, inSection section: Int) -> String {
        return playerAtRow(row, inSection: section).name
    }

    func isPlayerSelectedAtRow(row: Int, inSection section: Int) -> Bool {
        let player = playerAtRow(row, inSection: section)
        return selectedPlayers.value.contains(player)
    }

    func canSelectPlayerAtRow(row: Int, inSection section: Int) -> Bool {
        let player = playerAtRow(row, inSection: section)
        return !disabledPlayers.contains(player)
    }

    // MARK: Player Selection

    func selectPlayerAtRow(row: Int, inSection section: Int) {
        let player = playerAtRow(row, inSection: section)
        selectedPlayers.value.insert(player)
    }

    func deselectPlayerAtRow(row: Int, inSection section: Int) {
        let player = playerAtRow(row, inSection: section)
        selectedPlayers.value.remove(player)
    }

    // MARK: Internal Helpers

    private func playerAtRow(row: Int, inSection section: Int) -> Player {
        return players[row]
    }
}