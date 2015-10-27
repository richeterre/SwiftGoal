//
//  RankingsViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

class RankingsViewModel {

    // Inputs
    let active = MutableProperty(false)
    let refreshSink: Observer<Void, NoError>

    // Outputs
    let title: String
    let contentChangesSignal: Signal<Changeset, NoError>
    let isLoadingSignal: Signal<Bool, NoError>
    let alertMessageSignal: Signal<String, NoError>

    private let store: Store
    private let contentChangesSink: Observer<Changeset, NoError>
    private let isLoadingSink: Observer<Bool, NoError>
    private let alertMessageSink: Observer<String, NoError>

    private var rankings: [Ranking]

    // MARK: Lifecycle

    init(store: Store) {
        self.title = "Rankings"
        self.store = store
        self.rankings = []

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

        refreshSignal
            .on(next: { _ in isLoadingSink.sendNext(true) })
            .flatMap(.Latest, transform: { _ in
                return store.fetchRankings()
                    .flatMapError { error in
                        alertMessageSink.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])
                }
            })
            .on(next: { _ in isLoadingSink.sendNext(false) })
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldRankings, newRankings) in
                self?.rankings = newRankings
                if let sink = self?.contentChangesSink {
                    let changeset = Changeset(oldItems: oldRankings, newItems: newRankings)
                    sink.sendNext(changeset)
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
