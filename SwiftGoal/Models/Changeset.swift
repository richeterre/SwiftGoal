//
//  Changeset.swift
//  SwiftGoal
//
//  Created by Martin Richter on 01/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation

struct Changeset {
    let deletions: [NSIndexPath]
    let insertions: [NSIndexPath]

    init<T: Equatable>(oldItems: [T], newItems: [T]) {
        // Find index paths for deleted items
        var deletions: [NSIndexPath] = []
        for (index, item) in enumerate(oldItems) {
            if !contains(newItems, item) {
                deletions.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }

        // Find index paths for newly inserted items
        var insertions: [NSIndexPath] = []
        for (index, item) in enumerate(newItems) {
            if !contains(oldItems, item) {
                insertions.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }

        self.init(deletions: deletions, insertions: insertions)
    }

    private init(deletions: [NSIndexPath], insertions: [NSIndexPath]) {
        self.deletions = deletions
        self.insertions = insertions
    }
}
