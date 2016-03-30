//
//  RankingsViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa
import Result

class RankingsViewModel {

    typealias RankingChangeset = Changeset<Ranking>

    // Inputs
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>

    // Outputs
    let title: String
    let contentChangesSignal: Signal<RankingChangeset, NoError>
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<String, NoError>

    private let store: StoreType
    private let contentChangesObserver: Observer<RankingChangeset, NoError>
    private let alertMessageObserver: Observer<String, NoError>

    private var rankings: [Ranking]

    // MARK: Lifecycle

    init(store: StoreType) {
        self.title = "Rankings"
        self.store = store
        self.rankings = []

        let (refreshSignal, refreshObserver) = SignalProducer<Void, NoError>.buffer(0)
        self.refreshObserver = refreshObserver

        let (contentChangesSignal, contentChangesObserver) = Signal<RankingChangeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver

        let isLoading = MutableProperty(false)
        self.isLoading = isLoading

        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver

        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)

        refreshSignal
            .on(next: { _ in isLoading.value = true })
            .flatMap(.Latest, transform: { _ in
                return store.fetchRankings()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])
                }
            })
            .on(next: { _ in isLoading.value = false })
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldRankings, newRankings) in
                self?.rankings = newRankings
                if let observer = self?.contentChangesObserver {
                    let changeset = Changeset(
                        oldItems: oldRankings,
                        newItems: newRankings,
                        contentMatches: Ranking.contentMatches
                    )
                    observer.sendNext(changeset)
                }
            })
    }

    // MARK: Data Source

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRankingsInSection(section: Int) -> Int {
        return rankings.count
    }

    func playerNameAtIndexPath(indexPath: NSIndexPath) -> String {
        return rankingAtIndexPath(indexPath).player.name
    }

    func ratingAtIndexPath(indexPath: NSIndexPath) -> String {
        let rating = rankingAtIndexPath(indexPath).rating
        return String(format: "%.2f", rating)
    }

    // MARK: Internal Helpers

    private func rankingAtIndexPath(indexPath: NSIndexPath) -> Ranking {
        return rankings[indexPath.row]
    }
}
