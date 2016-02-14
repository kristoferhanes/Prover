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
    return String(self).uppercaseString.characters.first!
  }
}

private extension String {
  var withoutWhitespace: String {
    let whitespaceChars = NSCharacterSet.whitespaceCharacterSet()
    let filtered = unicodeScalars.filter {
      !whitespaceChars.characterIsMember(UInt16($0.value))
      }.map { Character($0) }
    return String(filtered)
  }

  func dropOutsideParens() -> String {
    guard characters.first == "(" && characters.last == ")" else { return self }
    return String(characters.dropFirst().dropLast())
  }
}

indirect enum Prop: Equatable {
  case Atom(Character)
  case Neg(Prop)
  case Conj(Prop, Prop)
  case Disj(Prop, Prop)
  case Impl(Prop, Prop)
  case Eqiv(Prop, Prop)
}

extension Prop {
  init(_ character: Character) {
    self = .Atom(character.uppercase)
  }

  init?(string: String) {
    guard let (result, remaining) = Prop.parser.parse(string.withoutWhitespace)
      where remaining == ""
      else { return nil }
    self = result
  }

  private static var parser: Parser<Prop> {
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
    func helper(prop: Prop) -> String {
      switch prop {
      case let .Neg(p): return "\(Const.NegStr)\(helper(p))"
      case let .Atom(c): return "\(c)"
      case let .Conj(l, r): return "(\(helper(l)) \(Const.ConjStr) \(helper(r)))"
      case let .Disj(l, r): return "(\(helper(l)) \(Const.DisjStr) \(helper(r)))"
      case let .Impl(a, c): return "(\(helper(a)) \(Const.ImplStr) \(helper(c)))"
      case let .Eqiv(l, r): return "(\(helper(l)) \(Const.EqivStr) \(helper(r)))"
      }
    }
    return helper(self).dropOutsideParens()
  }
}

extension Prop: Hashable {
  var hashValue: Int {
    switch self {
    case let .Neg(p): return 761 &* 1 &+ p.hashValue
    case let .Atom(c): return 761 &* 2 &+ c.hashValue
    case let .Conj(l, r): return 761 &* 3 &+ 37 &* l.hashValue &+ r.hashValue
    case let .Disj(l, r): return 761 &* 4 &+ 37 &* l.hashValue &+ r.hashValue
    case let .Impl(l, r): return 761 &* 5 &+ 37 &* l.hashValue &+ r.hashValue
    case let .Eqiv(l, r): return 761 &* 6 &+ 37 &* l.hashValue &+ r.hashValue
    }
  }
}

func && (lhs: Prop, rhs: Prop) -> Prop {
  return .Conj(lhs, rhs)
}

func || (lhs: Prop, rhs: Prop) -> Prop {
  return .Disj(lhs, rhs)
}

infix operator => { }

func => (lhs: Prop, rhs: Prop) -> Prop {
  return .Impl(lhs, rhs)
}

infix operator <=> { }

func <=> (lhs: Prop, rhs: Prop) -> Prop {
  return .Eqiv(lhs, rhs)
}

prefix func ~ (prop: Prop) -> Prop {
  guard case let .Neg(p) = prop else { return .Neg(prop) }
  return p
}

func == (lhs: Prop, rhs: Prop) -> Bool {
  switch (lhs, rhs) {
  case let (.Neg(l), .Neg(r)): return l == r
  case let (.Atom(l), .Atom(r)): return l == r
  case let (.Conj(l1,l2), .Conj(r1,r2)): return l1 == r1 && l2 == r2
  case let (.Disj(l1,l2), .Disj(r1,r2)): return l1 == r1 && l2 == r2
  case let (.Impl(l1,l2), .Impl(r1,r2)): return l1 == r1 && l2 == r2
  case let (.Eqiv(l1,l2), .Eqiv(r1,r2)): return l1 == r1 && l2 == r2
  default: return false
  }
}
