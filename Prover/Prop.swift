//
//  Prop.swift
//  Parser
//
//  Created by Kristofer Hanes on 2015 11 17.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//


import Foundation

private struct Const {
  static let DisjStr = "∨"
  static let ConjStr = "∧"
  static let ImplStr = "→"
  static let EqivStr = "⇔"
  static let NegStr = "¬"
}

private extension Character {
  var uppercase: Character {
    return String(self).uppercased().characters.first!
  }
}

private extension String {
  var withoutWhitespace: String {
    let whitespaceChars = CharacterSet.whitespaces
    let filtered = unicodeScalars.filter {
      !whitespaceChars.contains(UnicodeScalar(UInt16($0.value))!)
      }.map { Character($0) }
    return String(filtered)
  }

  func dropOutsideParens() -> String {
    guard characters.first == "(" && characters.last == ")" else { return self }
    return String(characters.dropFirst().dropLast())
  }
}

indirect enum Prop: Equatable {
  case atom(Character)
  case neg(Prop)
  case conj(Prop, Prop)
  case disj(Prop, Prop)
  case impl(Prop, Prop)
  case eqiv(Prop, Prop)
}

extension Prop {
  init(_ character: Character) {
    self = .atom(character.uppercase)
  }

  init?(string: String) {
    guard let (result, remaining) = Prop.parser.parse(string.withoutWhitespace)
      , remaining == ""
      else { return nil }
    self = result
  }

  fileprivate static var parser: Parser<Prop> {
    let opsParser = stringParser(Const.ConjStr).map { _ in { $0 && $1 } }
      ?? stringParser(Const.DisjStr).map { _ in { $0 || $1 } }
      ?? stringParser(Const.ImplStr).map { _ in { $0 => $1 }  }
      ?? stringParser(Const.EqivStr).map { _ in { $0 <=> $1 } }

    func termParser() -> Parser<Prop> {
      return product(stringParser(Const.NegStr), termParser()).map { ~$1 }
        ?? letterParser().map { Prop($0) }
        ?? bracketParser(
          open: characterParser("("),
          parser: propParser(),
          close: characterParser(")"))
    }

    func propParser() -> Parser<Prop> {
      return chainL1Parser(termParser(), operation: opsParser)
    }

    return propParser()
  }
}

extension Prop: CustomStringConvertible {
  var description: String {
    func helper(_ prop: Prop) -> String {
      switch prop {
      case let .neg(p): return "\(Const.NegStr)\(helper(p))"
      case let .atom(c): return "\(c)"
      case let .conj(l, r): return "(\(helper(l)) \(Const.ConjStr) \(helper(r)))"
      case let .disj(l, r): return "(\(helper(l)) \(Const.DisjStr) \(helper(r)))"
      case let .impl(a, c): return "(\(helper(a)) \(Const.ImplStr) \(helper(c)))"
      case let .eqiv(l, r): return "(\(helper(l)) \(Const.EqivStr) \(helper(r)))"
      }
    }
    return helper(self).dropOutsideParens()
  }
}

extension Prop: Hashable {
  var hashValue: Int {
    switch self {
    case let .neg(p): return 761 &* 1 &+ p.hashValue
    case let .atom(c): return 761 &* 2 &+ c.hashValue
    case let .conj(l, r): return 761 &* 3 &+ 37 &* l.hashValue &+ r.hashValue
    case let .disj(l, r): return 761 &* 4 &+ 37 &* l.hashValue &+ r.hashValue
    case let .impl(l, r): return 761 &* 5 &+ 37 &* l.hashValue &+ r.hashValue
    case let .eqiv(l, r): return 761 &* 6 &+ 37 &* l.hashValue &+ r.hashValue
    }
  }
}

func && (lhs: Prop, rhs: Prop) -> Prop {
  return .conj(lhs, rhs)
}

func || (lhs: Prop, rhs: Prop) -> Prop {
  return .disj(lhs, rhs)
}

infix operator =>

func => (lhs: Prop, rhs: Prop) -> Prop {
  return .impl(lhs, rhs)
}

infix operator <=>

func <=> (lhs: Prop, rhs: Prop) -> Prop {
  return .eqiv(lhs, rhs)
}

prefix func ~ (prop: Prop) -> Prop {
  guard case let .neg(p) = prop else { return .neg(prop) }
  return p
}

func == (lhs: Prop, rhs: Prop) -> Bool {
  switch (lhs, rhs) {
  case let (.neg(l), .neg(r)): return l == r
  case let (.atom(l), .atom(r)): return l == r
  case let (.conj(l1,l2), .conj(r1,r2)): return l1 == r1 && l2 == r2
  case let (.disj(l1,l2), .disj(r1,r2)): return l1 == r1 && l2 == r2
  case let (.impl(l1,l2), .impl(r1,r2)): return l1 == r1 && l2 == r2
  case let (.eqiv(l1,l2), .eqiv(r1,r2)): return l1 == r1 && l2 == r2
  default: return false
  }
}
