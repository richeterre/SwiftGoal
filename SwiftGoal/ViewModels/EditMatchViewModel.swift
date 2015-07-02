//
//  EditMatchViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 22/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa

class EditMatchViewModel {

    // Inputs
    let homeGoals = MutableProperty<Int>(0)
    let awayGoals = MutableProperty<Int>(0)

    // Outputs
    let title: String
    let formattedHomeGoals = MutableProperty<String>("")
    let formattedAwayGoals = MutableProperty<String>("")
    let homePlayersString = MutableProperty<String>("")
    let awayPlayersString = MutableProperty<String>("")
    let inputIsValid = MutableProperty<Bool>(false)

    // Actions
    lazy var saveAction: Action<Void, Bool, NoError> = { [unowned self] in
        return Action(enabledIf: self.inputIsValid, { _ in
            return self.store.createMatch(MatchParameters(
                homePlayers: self.homePlayers.value,
                awayPlayers: self.awayPlayers.value,
                homeGoals: self.homeGoals.value,
                awayGoals: self.awayGoals.value
            ))
        })
    }()

    private let store: Store
    private let homePlayers: MutableProperty<Set<Player>>
    private let awayPlayers: MutableProperty<Set<Player>>

    // MARK: Lifecycle

    init(store: Store) {
        self.title = "New Match"
        self.store = store
        self.homePlayers = MutableProperty<Set<Player>>(Set<Player>())
        self.awayPlayers = MutableProperty<Set<Player>>(Set<Player>())

        self.formattedHomeGoals <~ homeGoals.producer |> map { goals in return "\(goals)" }
        self.formattedAwayGoals <~ awayGoals.producer |> map { goals in return "\(goals)" }

        self.homePlayersString <~ homePlayers.producer
            |> map { players in
                return players.isEmpty ? "Set Home Players" : ", ".join(map(players, { $0.name }))
            }
        self.awayPlayersString <~ awayPlayers.producer
            |> map { players in
                return players.isEmpty ? "Set Away Players" : ", ".join(map(players, { $0.name }))
            }
        self.inputIsValid <~ combineLatest(homePlayers.producer, awayPlayers.producer)
            |> map { (homePlayers, awayPlayers) in
                return !homePlayers.isEmpty && !awayPlayers.isEmpty
            }
    }

    // MARK: View Models

    func manageHomePlayersViewModel() -> ManagePlayersViewModel {
        let homePlayersViewModel = ManagePlayersViewModel(
            store: store,
            initialPlayers: homePlayers.value,
            disabledPlayers: awayPlayers.value
        )
        self.homePlayers <~ homePlayersViewModel.selectedPlayers

        return homePlayersViewModel
    }

    func manageAwayPlayersViewModel() -> ManagePlayersViewModel {
        let awayPlayersViewModel = ManagePlayersViewModel(
            store: store,
            initialPlayers: awayPlayers.value,
            disabledPlayers: homePlayers.value
        )
        self.awayPlayers <~ awayPlayersViewModel.selectedPlayers

        return awayPlayersViewModel
    }
}
