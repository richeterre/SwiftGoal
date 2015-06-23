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

    private let store: Store

    // MARK: Lifecycle

    init(store: Store) {
        self.store = store

        self.formattedHomeGoals <~ homeGoals.producer |> map { goals in return "\(goals)" }
        self.formattedAwayGoals <~ awayGoals.producer |> map { goals in return "\(goals)" }
    }
}
