//
//  SwiftGoalTests.swift
//  SwiftGoalTests
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
import SwiftGoal

class ChangesetSpec: QuickSpec {

    override func spec() {

        let oldItems = ["A", "B", "C", "D"]

        describe("A Changeset") {

            context("after deleting items") {
                it("should return the correct deletions") {
                    let newItems = ["A", "C", "D"]
                    let changeset = Changeset(oldItems: oldItems, newItems: newItems)
                    let deletion = NSIndexPath(forRow: 1, inSection: 0) as NSIndexPath
                    expect(changeset.deletions).to(equal([deletion]))
                }
            }

            context("after inserting items") {
                it("should return the correct insertions") {
                    let newItems = ["A", "B", "C", "C2", "D"]
                    let changeset = Changeset(oldItems: oldItems, newItems: newItems)
                    let insertion = NSIndexPath(forRow: 3, inSection: 0) as NSIndexPath
                    XCTAssertEqual(changeset.insertions, [insertion], "")
                }
            }

            context("after deleting and inserting items") {
                it("should return the correct deletions and insertions") {
                    let newItems = ["A", "C", "C2", "D"]
                    let changeset = Changeset(oldItems: oldItems, newItems: newItems)
                    let deletion = NSIndexPath(forRow: 1, inSection: 0)
                    let insertion = NSIndexPath(forRow: 2, inSection: 0)
                    XCTAssertEqual(changeset.deletions, [deletion], "")
                    XCTAssertEqual(changeset.insertions, [insertion], "")
                }
            }
        }
    }
}
