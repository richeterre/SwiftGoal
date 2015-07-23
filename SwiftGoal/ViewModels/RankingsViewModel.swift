//
//  RankingsViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/07/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

class RankingsViewModel {

    // Outputs
    let title: String

    private let store: Store

    // MARK: Lifecycle

    init(store: Store) {
        self.store = store
        title = "Rankings"
    }
}
