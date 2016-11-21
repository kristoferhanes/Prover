//
//  Proposition.swift
//  Parser
//
//  Created by Kristofer Hanes on 2015 11 17.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//


import Foundation

private struct Const {
  static let DisjunctionString = "∨"
  static let ConjunctionString = "∧"
  static let ImplicationString = "→"
  static let EquivalenceString = "⇔"
  static let NegationString = "¬"
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
  
  var withoutOutsideParens: String {
    guard characters.first == "(" && characters.last == ")" else { return self }
    return String(characters.dropFirst().dropLast())
  }
}

indirect enum Proposition: Equatable {
  case atom(Character)
  case negation(Proposition)
  case conjunction(Proposition, Proposition)
  case disjunction(Proposition, Proposition)
  case implication(Proposition, Proposition)
  case eqivalence(Proposition, Proposition)
}

extension Proposition {
  init(_ character: Character) {
    self = .atom(character.uppercase)
  }
  
  init?(string: String) {
    guard let parsed = string.withoutWhitespace.parsed(with: Proposition.parser) else { return nil }
    self = parsed
  }
  
  private static var parser: Parser<Proposition> {
    let operations = Parse.string(matching: Const.ConjunctionString).map { _ in { $0 && $1 } }
                  ?? Parse.string(matching: Const.DisjunctionString).map { _ in { $0 || $1 } }
                  ?? Parse.string(matching: Const.ImplicationString).map { _ in { $0 => $1 }  }
                  ?? Parse.string(matching: Const.EquivalenceString).map { _ in { $0 <=> $1 } }
    
    func term() -> Parser<Proposition> {
      
      func negation() -> Parser<Proposition> {
        return curried { _, term in ~term } <^> Parse.string(matching: Const.NegationString) <*> term()
      }
      
      func atom() ->  Parser<Proposition> {
        return Parse.letter.map { Proposition($0) }
      }
      
      func brackets() ->  Parser<Proposition> {
        return Parse.bracket(
          open: Parse.character(matching: "("),
          parser: prop(),
          close: Parse.character(matching: ")")
        )
      }
      
      return negation() ?? atom() ?? brackets()
    }
    
    func prop() -> Parser<Proposition> {
      return term().chain(with: operations)
    }
    
    return prop()
  }
}

extension Proposition: CustomStringConvertible {
  var description: String {
    func helper(_ prop: Proposition) -> String {
      switch prop {
      case let .negation(p): return "\(Const.NegationString)\(helper(p))"
      case let .atom(c): return "\(c)"
      case let .conjunction(l, r): return "(\(helper(l)) \(Const.ConjunctionString) \(helper(r)))"
      case let .disjunction(l, r): return "(\(helper(l)) \(Const.DisjunctionString) \(helper(r)))"
      case let .implication(a, c): return "(\(helper(a)) \(Const.ImplicationString) \(helper(c)))"
      case let .eqivalence(l, r): return "(\(helper(l)) \(Const.EquivalenceString) \(helper(r)))"
      }
    }
    return helper(self).withoutOutsideParens
  }
}

extension Proposition: Hashable {
  var hashValue: Int {
    switch self {
    case let .negation(p): return 761 &* 1 &+ p.hashValue
    case let .atom(c): return 761 &* 2 &+ c.hashValue
    case let .conjunction(l, r): return 761 &* 3 &+ 37 &* l.hashValue &+ r.hashValue
    case let .disjunction(l, r): return 761 &* 4 &+ 37 &* l.hashValue &+ r.hashValue
    case let .implication(l, r): return 761 &* 5 &+ 37 &* l.hashValue &+ r.hashValue
    case let .eqivalence(l, r): return 761 &* 6 &+ 37 &* l.hashValue &+ r.hashValue
    }
  }
}

func && (lhs: Proposition, rhs: Proposition) -> Proposition {
  return .conjunction(lhs, rhs)
}

func || (lhs: Proposition, rhs: Proposition) -> Proposition {
  return .disjunction(lhs, rhs)
}

infix operator =>

func => (lhs: Proposition, rhs: Proposition) -> Proposition {
  return .implication(lhs, rhs)
}

infix operator <=>

func <=> (lhs: Proposition, rhs: Proposition) -> Proposition {
  return .eqivalence(lhs, rhs)
}

prefix func ~ (prop: Proposition) -> Proposition {
  guard case let .negation(p) = prop else { return .negation(prop) }
  return p
}

func == (lhs: Proposition, rhs: Proposition) -> Bool {
  switch (lhs, rhs) {
  case let (.negation(l), .negation(r)): return l == r
  case let (.atom(l), .atom(r)): return l == r
  case let (.conjunction(l1,l2), .conjunction(r1,r2)): return l1 == r1 && l2 == r2
  case let (.disjunction(l1,l2), .disjunction(r1,r2)): return l1 == r1 && l2 == r2
  case let (.implication(l1,l2), .implication(r1,r2)): return l1 == r1 && l2 == r2
  case let (.eqivalence(l1,l2), .eqivalence(r1,r2)): return l1 == r1 && l2 == r2
  default: return false
  }
}
