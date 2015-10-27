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
    let refreshSink: Observer<Void, NoError>

    // Outputs
    let title: String
    let contentChangesSignal: Signal<Changeset, NoError>
    let isLoadingSignal: Signal<Bool, NoError>
    let alertMessageSignal: Signal<String, NoError>
    let selectedPlayers: MutableProperty<Set<Player>>
    let inputIsValid = MutableProperty(false)

    // Actions
    lazy var saveAction: Action<Void, Bool, NSError> = { [unowned self] in
        return Action(enabledIf: self.inputIsValid, { _ in
            return self.store.createPlayerWithName(self.playerName.value)
        })
    }()

    private let store: Store
    private let contentChangesSink: Observer<Changeset, NoError>
    private let isLoadingSink: Observer<Bool, NoError>
    private let alertMessageSink: Observer<String, NoError>
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

        let (alertMessageSignal, alertMessageSink) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageSink = alertMessageSink

        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshSink)

        saveAction.values
            .filter { $0 }
            .map { _ in () }
            .observe(refreshSink)

        refreshSignal
            .on(next: { _ in isLoadingSink.sendNext(true) })
            .flatMap(.Latest, transform: { _ in
                return store.fetchPlayers()
                    .flatMapError { error in
                        alertMessageSink.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])
                    }
            })
            .on(next: { _ in isLoadingSink.sendNext(false) })
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldPlayers, newPlayers) in
                self?.players = newPlayers
                if let sink = self?.contentChangesSink {
                    let changeset = Changeset(oldItems: oldPlayers, newItems: newPlayers)
                    sink.sendNext(changeset)
                }
            })

        // Feed saving errors into alert message signal
        saveAction.errors
            .map { $0.localizedDescription }
            .observe(alertMessageSink)

        inputIsValid <~ playerName.producer.map { $0.characters.count > 0 }
    }

    // MARK: Data Source

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfPlayersInSection(section: Int) -> Int {
        return players.count
    }

    func playerNameAtIndexPath(indexPath: NSIndexPath) -> String {
        return playerAtIndexPath(indexPath).name
    }

    func isPlayerSelectedAtIndexPath(indexPath: NSIndexPath) -> Bool {
        let player = playerAtIndexPath(indexPath)
        return selectedPlayers.value.contains(player)
    }

    func canSelectPlayerAtIndexPath(indexPath: NSIndexPath) -> Bool {
        let player = playerAtIndexPath(indexPath)
        return !disabledPlayers.contains(player)
    }

    // MARK: Player Selection

    func selectPlayerAtIndexPath(indexPath: NSIndexPath) {
        let player = playerAtIndexPath(indexPath)
        selectedPlayers.value.insert(player)
    }

    func deselectPlayerAtIndexPath(indexPath: NSIndexPath) {
        let player = playerAtIndexPath(indexPath)
        selectedPlayers.value.remove(player)
    }

    // MARK: Internal Helpers

    private func playerAtIndexPath(indexPath: NSIndexPath) -> Player {
        return players[indexPath.row]
    }
}