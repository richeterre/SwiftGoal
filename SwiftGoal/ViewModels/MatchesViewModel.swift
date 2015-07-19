//
//  MatchesViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

class MatchesViewModel {

    // Inputs
    let active = MutableProperty(false)
    let refreshSink: SinkOf<Event<Void, NoError>>

    // Outputs
    let title: String
    let contentChangesSignal: Signal<Changeset, NoError>
    let isLoadingSignal: Signal<Bool, NoError>

    // Actions
    lazy var deleteAction: Action<NSIndexPath, Bool, NoError> = { [unowned self] in
        return Action({ indexPath in
            let match = self.matchAtIndexPath(indexPath)
            return self.store.deleteMatch(match)
        })
    }()

    private let store: Store
    private let contentChangesSink: SinkOf<Event<Changeset, NoError>>
    private let isLoadingSink: SinkOf<Event<Bool, NoError>>
    private var matches: [Match]

    // MARK: - Lifecycle

    init(store: Store) {
        self.title = "Matches"
        self.store = store
        self.matches = []

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

        deleteAction.values
            |> filter { $0 }
            |> map { _ in () }
            |> observe(refreshSink)

        refreshSignal
            |> on(next: { _ in sendNext(isLoadingSink, true) })
            |> flatMap(.Latest) { active in return store.fetchMatches() }
            |> on(next: { _ in sendNext(isLoadingSink, false) })
            |> combinePrevious([]) // Preserve history to calculate changeset
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

    func homePlayersAtIndexPath(indexPath: NSIndexPath) -> String {
        let match = matchAtIndexPath(indexPath)
        return separatedNamesForPlayers(match.homePlayers)
    }

    func awayPlayersAtIndexPath(indexPath: NSIndexPath) -> String {
        let match = matchAtIndexPath(indexPath)
        return separatedNamesForPlayers(match.awayPlayers)
    }

    func resultAtIndexPath(indexPath: NSIndexPath) -> String {
        let match = matchAtIndexPath(indexPath)
        return "\(match.homeGoals) : \(match.awayGoals)"
    }

    // MARK: View Models

    func editViewModelForNewMatch() -> EditMatchViewModel {
        return EditMatchViewModel(store: store)
    }

    func editViewModelForMatchAtIndexPath(indexPath: NSIndexPath) -> EditMatchViewModel {
        let match = matchAtIndexPath(indexPath)
        return EditMatchViewModel(store: store, match: match)
    }

    // MARK: Internal Helpers

    private func matchAtIndexPath(indexPath: NSIndexPath) -> Match {
        return matches[indexPath.row]
    }

    private func separatedNamesForPlayers(players: [Player]) -> String {
        let playerNames = players.map { player in player.name }
        return ", ".join(playerNames)
    }
}
