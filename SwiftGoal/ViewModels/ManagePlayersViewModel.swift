//
//  ManagePlayersViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 30/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation

class ManagePlayersViewModel {

    // Outputs
    let title: String

    private let store: Store

    // MARK: Lifecycle

    init(store: Store) {
        self.title = "Players"
        self.store = store
    }
}