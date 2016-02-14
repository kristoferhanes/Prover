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

  func testItemParser() {
    let parser = itemParser()
    XCTAssertNotNil(parser.parse("Hello"))
    XCTAssertEqual(parser.parse("Hello")?.result, "H")
    XCTAssertEqual(parser.parse("Hello")?.remaining, "ello")
    XCTAssertNil(parser.parse(""))
  }

  func testSatisfyParser() {
    let parser = satisfyParser { ch in ch == "H" }
    XCTAssertNotNil(parser.parse("Hello"))
    XCTAssertEqual(parser.parse("Hello")?.result, "H")
    XCTAssertEqual(parser.parse("Hello")?.remaining, "ello")
    XCTAssertNil(parser.parse(""))
  }

  func testCharacterParser() {
    let parser = characterParser("H")
    XCTAssertNotNil(parser.parse("Hello"))
    XCTAssertEqual(parser.parse("Hello")?.result, "H")
    XCTAssertEqual(parser.parse("Hello")?.remaining, "ello")
    XCTAssertNil(parser.parse(""))
  }

  func testDigitParser() {
    let parser = digitParser()
    XCTAssertNotNil(parser.parse("1234"))
    XCTAssertEqual(parser.parse("1234")?.result, "1")
    XCTAssertEqual(parser.parse("1234")?.remaining, "234")
    XCTAssertNil(parser.parse("abc"))
    XCTAssertNil(parser.parse(""))
  }

  func testLowercaseParser() {
    let parser = lowercaseCharacterParser()
    XCTAssertNotNil(parser.parse("hello"))
    XCTAssertEqual(parser.parse("hello")?.result, "h")
    XCTAssertEqual(parser.parse("hello")?.remaining, "ello")
    XCTAssertNil(parser.parse("Hello"))
    XCTAssertNil(parser.parse(""))
  }

  func testUppercaseParser() {
    let parser = uppercaseCharacterParser()
    XCTAssertNotNil(parser.parse("Hello"))
    XCTAssertEqual(parser.parse("Hello")?.result, "H")
    XCTAssertEqual(parser.parse("Hello")?.remaining, "ello")
    XCTAssertNil(parser.parse("hello"))
    XCTAssertNil(parser.parse(""))
  }

  func testLetterParser() {
    let parser = letterParser()
    XCTAssertNotNil(parser.parse("Hello"))
    XCTAssertEqual(parser.parse("Hello")?.result, "H")
    XCTAssertEqual(parser.parse("Hello")?.remaining, "ello")
    XCTAssertNotNil(parser.parse("hello"))
    XCTAssertEqual(parser.parse("hello")?.result, "h")
    XCTAssertEqual(parser.parse("hello")?.remaining, "ello")
    XCTAssertNil(parser.parse("123"))
    XCTAssertNil(parser.parse(""))
  }

  func testAlphaNumericParser() {
    let parser = alphaNumericParser()
    XCTAssertNotNil(parser.parse("Hello"))
    XCTAssertEqual(parser.parse("Hello")?.result, "H")
    XCTAssertEqual(parser.parse("Hello")?.remaining, "ello")
    XCTAssertNotNil(parser.parse("1234"))
    XCTAssertEqual(parser.parse("1234")?.result, "1")
    XCTAssertEqual(parser.parse("1234")?.remaining, "234")
    XCTAssertNil(parser.parse("!"))
    XCTAssertNil(parser.parse(""))
  }

  func testWordParser() {
    let parser = wordParser()
    XCTAssertNotNil(parser.parse("Hello, world!"))
    XCTAssertEqual(parser.parse("Hello, world!")?.result, "Hello")
    XCTAssertEqual(parser.parse("Hello, world!")?.remaining, ", world!")
    XCTAssertEqual(parser.parse("!")?.result, "")
    XCTAssertEqual(parser.parse("!")?.remaining, "!")
    XCTAssertEqual(parser.parse("1234")?.result, "")
    XCTAssertEqual(parser.parse("1234")?.remaining, "1234")
    XCTAssertEqual(parser.parse("!")?.result, "")
    XCTAssertEqual(parser.parse("!")?.remaining, "!")
    XCTAssertEqual(parser.parse("")?.result, "")
    XCTAssertEqual(parser.parse("")?.remaining, "")
  }

  func testStringParser() {
    let parser = stringParser("Hello")
    XCTAssertEqual(parser.parse("Hello, world!")?.result, "Hello")
    XCTAssertEqual(parser.parse("Hello, world!")?.remaining, ", world!")
    XCTAssertNil(parser.parse("world!"))
    XCTAssertNil(parser.parse(""))
  }

  func testManyParserString() {
    let parser = manyParser(letterParser())
    XCTAssertEqual(parser.parse("Hello, world!")?.result, "Hello")
    XCTAssertEqual(parser.parse("Hello, world!")?.remaining, ", world!")
    XCTAssertEqual(parser.parse("1234")?.result, "")
    XCTAssertEqual(parser.parse("1234")?.remaining, "1234")
    XCTAssertEqual(parser.parse("")?.result, "")
    XCTAssertEqual(parser.parse("")?.remaining, "")
  }

  func testManyParserArray() {
    let parser = manyParser(naturalNumberParser())
    XCTAssertEqual((parser.parse("1234")?.result)!, [1234])
    XCTAssertEqual(parser.parse("1234")?.remaining, "")
    XCTAssertEqual((parser.parse("hello")?.result)!, [])
    XCTAssertEqual(parser.parse("hello")?.remaining, "hello")
    XCTAssertEqual((parser.parse("")?.result)!, [])
    XCTAssertEqual(parser.parse("")?.remaining, "")
  }

  func testIdentifierParser() {
    let parser = identifierParser()
    XCTAssertNotNil(parser.parse("hello world"))
    XCTAssertEqual(parser.parse("hello world")?.result, "hello")
    XCTAssertEqual(parser.parse("hello world")?.remaining, " world")
    XCTAssertNil(parser.parse("1234"))
    XCTAssertNil(parser.parse(""))
  }

  func testMany1ParserString() {
    let parser = many1Parser(letterParser())
    XCTAssertEqual(parser.parse("hello world")?.result, "hello")
    XCTAssertEqual(parser.parse("hello world")?.remaining, " world")
    XCTAssertNil(parser.parse("1234"))
  }

  func testMany1ParserArray() {
    let parser = many1Parser(naturalNumberParser())
    XCTAssertNotNil(parser.parse("1234 1234"))
    XCTAssertEqual((parser.parse("1234 1234")?.result)!, [1234])
    XCTAssertEqual(parser.parse("1234 1234")?.remaining, " 1234")
    XCTAssertNil(parser.parse("hello"))
  }

  func testNaturalNumberParser() {
    let parser = naturalNumberParser()
    XCTAssertEqual(parser.parse("1234 1234")?.result, 1234)
    XCTAssertEqual(parser.parse("1234 1234")?.remaining, " 1234")
    XCTAssertNil(parser.parse("-1234"))
    XCTAssertNil(parser.parse("hello"))
  }

  func testIntegerParser() {
    let parser = integerParser()
    XCTAssertEqual(parser.parse("-1234 1234")?.result, -1234)
    XCTAssertEqual(parser.parse("-1234 1234")?.remaining, " 1234")
    XCTAssertEqual(parser.parse("1234 1234")?.result, 1234)
    XCTAssertEqual(parser.parse("1234 1234")?.remaining, " 1234")
    XCTAssertNil(parser.parse("hello"))
  }

  func testSeparateBy1Parser() {
    let parser = separateBy1Parser(integerParser(), separator: characterParser(" "))
    XCTAssertNotNil(parser.parse("1234 1234"))
    XCTAssertEqual((parser.parse("1234 1234")?.result)!, [1234, 1234])
    XCTAssertEqual(parser.parse("1234 1234")?.remaining, "")
    XCTAssertEqual((parser.parse("1234 hello")?.result)!, [1234])
    XCTAssertEqual(parser.parse("1234 hello")?.remaining, " hello")
    XCTAssertNil(parser.parse("hello"))
    XCTAssertNil(parser.parse(""))
  }

  func testSeparateByParser() {
    let parser = separateByParser(integerParser(), separator: characterParser(" "))
    XCTAssertNotNil(parser.parse("1234 1234"))
    XCTAssertEqual((parser.parse("1234 1234")?.result)!, [1234, 1234])
    XCTAssertEqual(parser.parse("1234 1234")?.remaining, "")
    XCTAssertEqual((parser.parse("1234 hello")?.result)!, [1234])
    XCTAssertEqual(parser.parse("1234 hello")?.remaining, " hello")
    XCTAssertEqual((parser.parse("hello")?.result)!, [])
    XCTAssertEqual(parser.parse("hello")?.remaining, "hello")
    XCTAssertEqual((parser.parse("")?.result)!, [])
    XCTAssertEqual(parser.parse("")?.remaining, "")
  }

  func testBracketParser() {
    let parser = bracketParser(
      open: characterParser("["),
      parser: separateBy1Parser(letterParser(), separator: characterParser(",")),
      close: characterParser("]"))
    XCTAssertNil(parser.parse("hello"))
    XCTAssertNil(parser.parse("[1,2,3,4,5]"))
    XCTAssertEqual((parser.parse("[h,e,l,l,o]")?.result)!, ["h","e","l","l","o"])
    XCTAssertEqual(parser.parse("[h,e,l,l,o]")?.remaining, "")
    XCTAssertEqual((parser.parse("[h,e,l,l,o] world")?.result)!, ["h","e","l","l","o"])
    XCTAssertEqual(parser.parse("[h,e,l,l,o] world")?.remaining, " world")
  }

  func testIntegersParser() {
    let parser = integersParser()
    XCTAssertNil(parser.parse("hello"))
    XCTAssertNil(parser.parse("[h,e,l,l,o]"))
    XCTAssertEqual((parser.parse("[1,2,3,4,5]")?.result)!, [1,2,3,4,5])
    XCTAssertEqual(parser.parse("[1,2,3,4,5]")?.remaining, "")
    XCTAssertEqual((parser.parse("[1,2,3,4,5] world")?.result)!, [1,2,3,4,5])
    XCTAssertEqual(parser.parse("[1,2,3,4,5] world")?.remaining, " world")
  }

  func testChain1LParser() {
    let add: (Int,Int)->Int = { $0 + $1 }
    let subtract: (Int,Int)->Int = { $0 - $1 }
    let addOp = characterParser("+").map { _ in add }
      ?? characterParser("-").map { _ in subtract }
    func factor() -> Parser<Int> {
      return naturalNumberParser() ?? bracketParser(
        open: characterParser("("),
        parser: expr(),
        close: characterParser(")"))
    }
    func expr() -> Parser<Int> {
      return chainL1Parser(factor(), operation: addOp)
    }
    let parser = chainL1Parser(factor(), operation: addOp)
    XCTAssertEqual(parser.parse("1+1")?.result, 2)
    XCTAssertEqual(parser.parse("1+1")?.remaining, "")
    XCTAssertEqual(parser.parse("1-1")?.result, 0)
    XCTAssertEqual(parser.parse("1-1")?.remaining, "")
    XCTAssertEqual(parser.parse("10+(6-3)+4")?.result, 17)
    XCTAssertEqual(parser.parse("10+(6-3)+4")?.remaining, "")
    XCTAssertNil(parser.parse("Hello"))
    XCTAssertNil(parser.parse(""))
  }

  func testChain1LParser2() {
    indirect enum Expr {
      case Value(Int)
      case Add(Expr, Expr)
      case Subtract(Expr, Expr)

      var evaluate: Int {
        switch self {
        case let .Value(n): return n
        case let .Add(expr1, expr2): return expr1.evaluate + expr2.evaluate
        case let .Subtract(expr1, expr2): return expr1.evaluate - expr2.evaluate
        }
      }
    }

    let add: (Expr,Expr)->Expr = { .Add($0, $1) }
    let subtract: (Expr,Expr)->Expr = { .Subtract($0, $1) }
    let addOp = characterParser("+").map { _ in add }
      ?? characterParser("-").map { _ in subtract }
    func factor() -> Parser<Expr> {
      return naturalNumberParser().map { .Value($0) } ?? bracketParser(
        open: characterParser("("),
        parser: expr(),
        close: characterParser(")"))
    }
    func expr() -> Parser<Expr> {
      return chainL1Parser(factor(), operation: addOp)
    }
    let parser = chainL1Parser(factor(), operation: addOp)
    XCTAssertEqual(parser.parse("1+1")?.result.evaluate, 2)
    XCTAssertEqual(parser.parse("1+1")?.remaining, "")
    XCTAssertEqual(parser.parse("1-1")?.result.evaluate, 0)
    XCTAssertEqual(parser.parse("1-1")?.remaining, "")
    XCTAssertEqual(parser.parse("10+(6-3)+4")?.result.evaluate, 17)
    XCTAssertEqual(parser.parse("10+(6-3)+4")?.remaining, "")
    XCTAssertNil(parser.parse("Hello"))
    XCTAssertNil(parser.parse(""))
  }

  func testPropParser() {
    let opsParser = stringParser("&&").map { _ in { $0 && $1 } }
      ?? stringParser("||").map { _ in { $0 || $1 } }
      ?? stringParser("=>").map { _ in { $0 => $1 }  }
      ?? stringParser("<=>").map { _ in { $0 <=> $1 } }

    func termParser() -> Parser<Prop> {
      return product(characterParser("~"), termParser()).map { ~$1 }
        ?? letterParser().map { Prop($0) }
        ?? bracketParser(
          open: characterParser("("),
          parser: propParser(),
          close: characterParser(")"))
    }

    func propParser() -> Parser<Prop> {
      return chainL1Parser(termParser(), operation: opsParser)
    }

    let parser = propParser()
    XCTAssertEqual(parser.parse("P&&Q")?.result, Prop("P") && Prop("Q"))
    XCTAssertEqual(parser.parse("P&&Q")?.remaining, "")
    XCTAssertEqual(parser.parse("P||Q")?.result, Prop("P") || Prop("Q"))
    XCTAssertEqual(parser.parse("P||Q")?.remaining, "")
    XCTAssertEqual(parser.parse("P&&(Q||R)&&S")?.result, Prop("P") && (Prop("Q") || Prop("R")) && Prop("S"))
    XCTAssertEqual(parser.parse("P&&(Q||R)&&S")?.remaining, "")
    XCTAssertEqual(parser.parse("P=>Q")?.result, Prop("P") => Prop("Q"))
    XCTAssertEqual(parser.parse("P=>Q")?.remaining, "")
    XCTAssertEqual(parser.parse("P<=>Q")?.result, Prop("P") <=> Prop("Q"))
    XCTAssertEqual(parser.parse("P<=>Q")?.remaining, "")
    XCTAssertEqual(parser.parse("~P&&Q")?.result, ~Prop("P") && Prop("Q"))
    XCTAssertEqual(parser.parse("~P&&Q")?.remaining, "")
    XCTAssertEqual(parser.parse("~(P&&Q)")?.result, ~(Prop("P") && Prop("Q")))
    XCTAssertEqual(parser.parse("~(P&&Q)")?.remaining, "")
    XCTAssertEqual(parser.parse("P&&~Q")?.result, Prop("P") && ~Prop("Q"))
    XCTAssertEqual(parser.parse("P&&~Q")?.remaining, "")
    XCTAssertEqual(parser.parse("~~P&&Q")?.result, Prop("P") && Prop("Q"))
    XCTAssertEqual(parser.parse("~~P&&Q")?.remaining, "")
    XCTAssertNil(parser.parse(""))
  }

  func testPropParserInit() {
    XCTAssertEqual(Prop(string: "P ∧ Q"), Prop("P") && Prop("Q"))
    XCTAssertEqual(Prop(string: "P ∨ Q"), Prop("P") || Prop("Q"))
    XCTAssertEqual(Prop(string: "P ∧ (Q ∨ R) ∧ S"), Prop("P") && (Prop("Q") || Prop("R")) && Prop("S"))
    XCTAssertEqual(Prop(string: "P → Q"), Prop("P") => Prop("Q"))
    XCTAssertEqual(Prop(string: "P ⇔ Q"), Prop("P") <=> Prop("Q"))
    XCTAssertEqual(Prop(string: "¬P ∧ Q"), ~Prop("P") && Prop("Q"))
    XCTAssertEqual(Prop(string: "¬(P ∧ Q)"), ~(Prop("P") && Prop("Q")))
    XCTAssertEqual(Prop(string: "P ∧ ¬Q"), Prop("P") && ~Prop("Q"))
    XCTAssertEqual(Prop(string: "¬¬P ∧ Q"), Prop("P") && Prop("Q"))
  }

}














































