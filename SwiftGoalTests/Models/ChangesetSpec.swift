//
//  SwiftGoalTests.swift
//  SwiftGoalTests
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftGoal

private struct Item: Equatable {
    let identifier: String
    let value: String
}

private func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.identifier == rhs.identifier
}

class ChangesetSpec: QuickSpec {

    override func spec() {

        let oldItems = [
            Item(identifier: "cat", value: "Cat"),
            Item(identifier: "dog", value: "Dog"),
            Item(identifier: "fox", value: "Fox"),
            Item(identifier: "rat", value: "Rat"),
            Item(identifier: "yak", value: "Yak")
        ]

        describe("A Changeset") {

            it("should have the correct insertions, deletions and modifications") {
                let newItems = [
                    Item(identifier: "bat", value: "Bat"),
                    Item(identifier: "cow", value: "Cow"),
                    Item(identifier: "dog", value: "A different dog"),
                    Item(identifier: "fox", value: "Fox"),
                    Item(identifier: "pig", value: "Pig"),
                    Item(identifier: "yak", value: "A different yak")
                ]

                let changeset = Changeset(
                    oldItems: oldItems,
                    newItems: newItems,
                    contentMatches: { item1, item2 in item1.value == item2.value }
                )

                let deletion1 = NSIndexPath(forRow: 0, inSection: 0)
                let deletion2 = NSIndexPath(forRow: 3, inSection: 0)

                let modification1 = NSIndexPath(forRow: 1, inSection: 0)
                let modification2 = NSIndexPath(forRow: 4, inSection: 0)

                let insertion1 = NSIndexPath(forRow: 0, inSection: 0)
                let insertion2 = NSIndexPath(forRow: 1, inSection: 0)
                let insertion3 = NSIndexPath(forRow: 4, inSection: 0)

                expect(changeset.deletions).to(equal([deletion1, deletion2]))
                expect(changeset.modifications).to(equal([modification1, modification2]))
                expect(changeset.insertions).to(equal([insertion1, insertion2, insertion3]))
            }
        }
    }
}
