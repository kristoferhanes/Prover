//
//  ParserTests.swift
//  ParserTests
//
//  Created by Kristofer Hanes on 2015 11 10.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import XCTest
@testable import Prover

class ParserTests: XCTestCase {
  
  func testManyParser() {
    let parser = Parse.string(matching: "abc").many
    XCTAssertEqual((parser.parsing("")?.result)!, [])
    XCTAssertEqual((parser.parsing("abc")?.result)!, ["abc"])
    XCTAssertEqual((parser.parsing("abcabc")?.result)!, ["abc", "abc"])
  }
  
  func testChainParser() {
    let addition: Parser<(Int, Int) -> Int> =
      Parse.string(matching: "+").map { _ in { $0 + $1 } }
    let digit = Parse.satisfying { "0" <= $0 && $0 <= "9" }
    let int = digit.many.map { Int(String($0))! }
    let parser = int.chain(with: addition)
    XCTAssertEqual(parser.parsing("1+2")?.result, 3)
  }
  
  func testBracketParser() {
    let parser = Parse.bracket(
      open: Parse.character(matching: "("),
      parser: Parse.string(matching: "abc"),
      close: Parse.character(matching: ")"))
    XCTAssertEqual(parser.parsing("(abc)")?.result, "abc")
  }

  func testPropParserInit() {
    XCTAssertEqual(Proposition(string: "P ∧ Q"), Proposition("P") && Proposition("Q"))
    XCTAssertEqual(Proposition(string: "P ∨ Q"), Proposition("P") || Proposition("Q"))
    XCTAssertEqual(Proposition(string: "P ∧ (Q ∨ R) ∧ S"), Proposition("P") && (Proposition("Q") || Proposition("R")) && Proposition("S"))
    XCTAssertEqual(Proposition(string: "P → Q"), Proposition("P") => Proposition("Q"))
    XCTAssertEqual(Proposition(string: "P ⇔ Q"), Proposition("P") <=> Proposition("Q"))
    XCTAssertEqual(Proposition(string: "¬P ∧ Q"), ~Proposition("P") && Proposition("Q"))
    XCTAssertEqual(Proposition(string: "¬(P ∧ Q)"), ~(Proposition("P") && Proposition("Q")))
    XCTAssertEqual(Proposition(string: "P ∧ ¬Q"), Proposition("P") && ~Proposition("Q"))
    XCTAssertEqual(Proposition(string: "¬¬P ∧ Q"), Proposition("P") && Proposition("Q"))
  }
  
}














































