//
//  PlayerSpec.swift
//  SwiftGoal
//
//  Created by Martin Richter on 15/11/15.
//  Copyright © 2015 Martin Richter. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftGoal

class PlayerSpec: QuickSpec {

    override func spec() {
        describe("A Player") {
            it("is equal to another Player iff (if and only if) their identifiers match") {
                let p1 = Player(identifier: "a", name: "")
                let p2 = Player(identifier: "a", name: "")
                let p3 = Player(identifier: "b", name: "")
                expect(p1).to(equal(p2))
                expect(p1).notTo(equal(p3))
            }

            context("when compared by content to another Player") {

                it("does not match when the identifiers differ") {
                    let p1 = Player(identifier: "a", name: "")
                    let p2 = Player(identifier: "b", name: "")
                    expect(Player.contentMatches(p1, p2)).to(beFalse())
                }

                it("does not match when the names differ") {
                    let p1 = Player(identifier: "a", name: "John")
                    let p2 = Player(identifier: "a", name: "Jack")
                    expect(Player.contentMatches(p1, p2)).to(beFalse())
                }

                it("matches when all properties match") {
                    let p1 = Player(identifier: "a", name: "John")
                    let p2 = Player(identifier: "a", name: "John")
                    expect(Player.contentMatches(p1, p2)).to(beTrue())
                }
            }
        }
    }
}
