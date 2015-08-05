//
//  SwiftGoalTests.swift
//  SwiftGoalTests
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import SwiftGoal
import XCTest

class ChangesetTests: XCTestCase {

    let oldItems = ["A", "B", "C", "D"]

    func testDeletions() {
        let newItems = ["A", "C", "D"]
        let changeset = Changeset(oldItems: oldItems, newItems: newItems)
        let deletion = NSIndexPath(forRow: 1, inSection: 0) as NSIndexPath
        XCTAssertEqual(changeset.deletions, [deletion], "")
    }

    func testInsertions() {
        let newItems = ["A", "B", "C", "C2", "D"]
        let changeset = Changeset(oldItems: oldItems, newItems: newItems)
        let insertion = NSIndexPath(forRow: 3, inSection: 0) as NSIndexPath
        XCTAssertEqual(changeset.insertions, [insertion], "")
    }

    func testInsertionsAndDeletions() {
        let newItems = ["A", "C", "C2", "D"]
        let changeset = Changeset(oldItems: oldItems, newItems: newItems)
        let deletion = NSIndexPath(forRow: 1, inSection: 0)
        let insertion = NSIndexPath(forRow: 2, inSection: 0)
        XCTAssertEqual(changeset.deletions, [deletion], "")
        XCTAssertEqual(changeset.insertions, [insertion], "")
    }
}
