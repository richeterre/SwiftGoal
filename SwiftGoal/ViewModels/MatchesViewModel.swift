//
//  MatchesViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

class MatchesViewModel {

    typealias MatchChangeset = Changeset<Match>

    // Inputs
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>

    // Outputs
    let title: String
    let contentChangesSignal: Signal<MatchChangeset, NoError>
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<String, NoError>

    // Actions
    lazy var deleteAction: Action<NSIndexPath, Bool, NSError> = { [unowned self] in
        return Action({ indexPath in
            let match = self.matchAtIndexPath(indexPath)
            return self.store.deleteMatch(match)
        })
    }()

    private let store: StoreType
    private let contentChangesObserver: Observer<MatchChangeset, NoError>
    private let alertMessageObserver: Observer<String, NoError>
    private var matches: [Match]

    // MARK: - Lifecycle

    init(store: StoreType) {
        self.title = "Matches"
        self.store = store
        self.matches = []

        let (refreshSignal, refreshObserver) = SignalProducer<Void, NoError>.buffer()
        self.refreshObserver = refreshObserver

        let (contentChangesSignal, contentChangesObserver) = Signal<MatchChangeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver

        let isLoading = MutableProperty(false)
        self.isLoading = isLoading

        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver

        // Trigger refresh when view becomes active
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)

        // Trigger refresh after deleting a match
        deleteAction.values
            .filter { $0 }
            .map { _ in () }
            .observe(refreshObserver)

        refreshSignal
            .on(next: { _ in isLoading.value = true })
            .flatMap(.Latest) { _ in
                return store.fetchMatches()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])
                    }
            }
            .on(next: { _ in isLoading.value = false })
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldMatches, newMatches) in
                self?.matches = newMatches
                if let observer = self?.contentChangesObserver {
                    let changeset = Changeset(
                        oldItems: oldMatches,
                        newItems: newMatches,
                        contentMatches: Match.contentMatches
                    )
                    observer.sendNext(changeset)
                }
            })

        // Feed deletion errors into alert message signal
        deleteAction.errors
            .map { $0.localizedDescription }
            .observe(alertMessageObserver)
    }

    // MARK: - Data Source

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfMatchesInSection(section: Int) -> Int {
        return matches.count
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
        return playerNames.joinWithSeparator(", ")
    }
}
