//
//  TruthTreeTests.swift
//  TruthTreeTests
//
//  Created by Kristofer Hanes on 2015 11 28.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import XCTest
@testable import Prover

class TruthTreeTests: XCTestCase {

  func testTruthTree() {
    let props1 = ["P → Q", "P", "¬Q"].compactMap(Proposition.init)
    let tree1 = TruthTree(props1)
    XCTAssertEqual(tree1.isConsistent, false)
    let props2 = ["P → Q", "P", "Q"].compactMap(Proposition.init)
    let tree2 = TruthTree(props2)
    XCTAssertEqual(tree2.isConsistent, true)
    let props3 = ["P → Q", "¬Q", "P"].compactMap(Proposition.init)
    let tree3 = TruthTree(props3)
    XCTAssertEqual(tree3.isConsistent, false)
    let props4 = ["P → Q", "¬Q", "¬P"].compactMap(Proposition.init)
    let tree4 = TruthTree(props4)
    XCTAssertEqual(tree4.isConsistent, true)
    let props5 = ["¬(¬(Z ∨ K) ⇔ (¬Z ∧ ¬K))"].compactMap(Proposition.init)
    let tree5 = TruthTree(props5)
    XCTAssertEqual(tree5.isConsistent, false)
    let props6 = ["¬(((P ∧ Q) → R) ⇔ (P → (¬Q ∨ R)))"].compactMap(Proposition.init)
    let tree6 = TruthTree(props6)
    XCTAssertEqual(tree6.isConsistent, false)
  }

  func testArgument() {
    let argument1 = Argument(premises: ["P → Q", "P"].compactMap(Proposition.init), conclusion: Proposition("Q"))
    XCTAssertEqual(argument1.isValid, true)
    let argument2 = Argument(premises: ["P → Q", "P"].compactMap(Proposition.init), conclusion: ~Proposition("Q"))
    XCTAssertEqual(argument2.isValid, false)
    let argument3 = Argument(premises: ["P → Q", "¬Q"].compactMap(Proposition.init), conclusion: Proposition("P"))
    XCTAssertEqual(argument3.isValid, false)
    let argument4 = Argument(premises: ["P → Q", "¬Q"].compactMap(Proposition.init), conclusion: ~Proposition("P"))
    XCTAssertEqual(argument4.isValid, true)
    let argument5 = Argument(premises: ["Q", "¬Q"].compactMap(Proposition.init), conclusion: Proposition("P"))
    XCTAssertEqual(argument5.isValid, true)
    let argument6 = Argument(premises: ["(A → B) ∧ (C → D)", "A ∨ C"].compactMap(Proposition.init), conclusion: Proposition(string: "B ∨ D")!)
    XCTAssertEqual(argument6.isValid, true)
  }

}
