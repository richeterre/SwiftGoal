//
//  MatchesViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

public class MatchesViewModel {

    // Inputs
    public let active = MutableProperty(false)
    public let refreshSink: SinkOf<Event<Void, NoError>>

    // Outputs
    public let title: String
    public let contentChangesSignal: Signal<Changeset, NoError>
    let isLoadingSignal: Signal<Bool, NoError>
    let alertMessageSignal: Signal<String, NoError>

    // Actions
    public lazy var deleteAction: Action<NSIndexPath, Bool, NSError> = { [unowned self] in
        return Action({ indexPath in
            let match = self.matchAtIndexPath(indexPath)
            return self.store.deleteMatch(match)
        })
    }()

    private let store: Store
    private let contentChangesSink: SinkOf<Event<Changeset, NoError>>
    private let isLoadingSink: SinkOf<Event<Bool, NoError>>
    private let alertMessageSink: SinkOf<Event<String, NoError>>
    private var matches: [Match]

    // MARK: - Lifecycle

    public init(store: Store) {
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

        let (alertMessageSignal, alertMessageSink) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageSink = alertMessageSink

        // Trigger refresh when view becomes active
        active.producer
            |> filter { $0 }
            |> map { _ in () }
            |> start(refreshSink)

        // Trigger refresh after deleting a match
        deleteAction.values
            |> filter { $0 }
            |> map { _ in () }
            |> observe(refreshSink)

        refreshSignal
            |> on(next: { _ in sendNext(isLoadingSink, true) })
            |> flatMap(.Latest) { _ in
                return store.fetchMatches()
                    |> catch { error in
                        sendNext(alertMessageSink, error.localizedDescription)
                        return SignalProducer(value: [])
                    }
            }
            |> on(next: { _ in sendNext(isLoadingSink, false) })
            |> combinePrevious([]) // Preserve history to calculate changeset
            |> start(next: { [weak self] (oldMatches, newMatches) in
                self?.matches = newMatches
                if let sink = self?.contentChangesSink {
                    let changeset = Changeset(oldItems: oldMatches, newItems: newMatches)
                    sendNext(sink, changeset)
                }
            })

        // Feed deletion errors into alert message signal
        deleteAction.errors
            |> map { $0.localizedDescription }
            |> observe(alertMessageSink)
    }

    // MARK: - Data Source

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfMatchesInSection(section: Int) -> Int {
        return count(matches)
    }

    public func homePlayersAtIndexPath(indexPath: NSIndexPath) -> String {
        let match = matchAtIndexPath(indexPath)
        return separatedNamesForPlayers(match.homePlayers)
    }

    public func awayPlayersAtIndexPath(indexPath: NSIndexPath) -> String {
        let match = matchAtIndexPath(indexPath)
        return separatedNamesForPlayers(match.awayPlayers)
    }

    public func resultAtIndexPath(indexPath: NSIndexPath) -> String {
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
