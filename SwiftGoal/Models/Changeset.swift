//
//  Changeset.swift
//  SwiftGoal
//
//  Created by Martin Richter on 01/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation

public struct Changeset {

    public let deletions: [NSIndexPath]
    public let insertions: [NSIndexPath]

    public init<T: Equatable>(oldItems: [T], newItems: [T]) {
        // Find index paths for deleted items
        var deletions: [NSIndexPath] = []
        for (index, item) in oldItems.enumerate() {
            if !newItems.contains(item) {
                deletions.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }

        // TODO: Compare edited changes within matches

        // Find index paths for newly inserted items
        var insertions: [NSIndexPath] = []
        for (index, item) in newItems.enumerate() {
            if !oldItems.contains(item) {
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
