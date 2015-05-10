//
//  MatchesViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation

class MatchesViewModel: NSObject {

    let store: Store

    // MARK: - Lifecycle

    init(store: Store) {
        self.store = store
        super.init()
    }

    // MARK: - Data Source

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfMatchesInSection(section: Int) -> Int {
        return 1
    }

    func matchAtRow(row: Int, inSection: Int) -> String {
        return "Match"
    }
}
