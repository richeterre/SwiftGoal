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

    init(store: Store) {
        self.store = store
        super.init()
    }
}
