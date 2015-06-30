//
//  EditMatchViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 22/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation
import ReactiveCocoa

class EditMatchViewModel {

    // Inputs
    let homeGoals = MutableProperty<Int>(0)
    let awayGoals = MutableProperty<Int>(0)

    // Outputs
    let formattedHomeGoals = MutableProperty<String>("")
    let formattedAwayGoals = MutableProperty<String>("")

    // Actions
    lazy var saveAction: Action<Void, Bool, NoError> = { [unowned self] in
        return Action({ _ in
            let homePlayers = Set([
                Player(identifier: "ff26714d-f4a8-4306-a0f8-ca6023a05c20", name: "Martin")
            ])
            let awayPlayers = Set(
                [Player(identifier: "fe858866-2a95-4710-87dc-46e92eacd098", name: "Olli")]
            )
            return self.store.createMatch(homePlayers: homePlayers, awayPlayers: awayPlayers, homeGoals: self.homeGoals.value, awayGoals: self.awayGoals.value)
        })
    }()

    private let store: Store

    // MARK: Lifecycle

    init(store: Store) {
        self.store = store

        self.formattedHomeGoals <~ homeGoals.producer |> map { goals in return "\(goals)" }
        self.formattedAwayGoals <~ awayGoals.producer |> map { goals in return "\(goals)" }
    }
}
