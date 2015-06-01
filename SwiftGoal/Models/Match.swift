//
//  Match.swift
//  SwiftGoal
//
//  Created by Martin Richter on 11/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

struct Match {
    let identifier: String
    let homeGoals: Int
    let awayGoals: Int
}

extension Match: Equatable {}

func ==(lhs: Match, rhs: Match) -> Bool {
    return lhs.identifier == rhs.identifier
}