//
//  Parser.swift
//  Parser
//
//  Created by Kristofer Hanes on 2015 11 10.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import Foundation

struct Parser<Parsed> {
  typealias Stream = Substring
  fileprivate let parse: (Stream) -> (Parsed, Stream)?
  
  func parsing(_ input: String) -> (result: Parsed, remaining: String)? {
    guard let (parsed, remaining) = parse(Substring(input)) else { return nil }
    return (parsed, String(remaining))
  }
}

extension String {
  func parsed<Parsed>(with parser: Parser<Parsed>) -> Parsed? {
    guard let (parsed, remaining) = parser.parse(Substring(self)), remaining.isEmpty else { return nil }
    return parsed
  }
}

extension Parser {
  var many: Parser<[Parsed]> {
    return Parser<[Parsed]> { [parse] stream in
      var stream = stream
      var result: [Parsed] = []
      while let (parsed, remaining) = parse(stream) {
        result.append(parsed)
        stream = remaining
      }
      return (result, stream)
    }
  }
  
  func chain(with operation: Parser<(Parsed, Parsed) -> Parsed>) -> Parser {
    let pair = curried { ($0, $1) } <^> operation <*> self
    let sequence = curried { f, y in (f, y) } <^> self <*> pair.many
    return sequence.map { x, fys in
      fys.reduce(x) { accum, z in
        let (f, y) = z;
        return f(accum, y)
      }
    }
  }
}

extension Parser {
  init() {
    self.init { _ in nil }
  }
  
  init(_ value: Parsed) {
    self.init { stream in (value, stream) }
  }
  
  func map<Mapped>(_ transform: @escaping (Parsed) -> Mapped) -> Parser<Mapped> {
    return Parser<Mapped> { [parse] stream in
      parse(stream).map { parsed, remaining in (transform(parsed), remaining) }
    }
  }
  
  func flatMap<Mapped>(_ transform: @escaping (Parsed) -> Mapped?) -> Parser<Mapped> {
    return Parser<Mapped> { [parse] stream in
      parse(stream).flatMap { parsed, remaining in transform(parsed).map { ($0, remaining) } }
    }
  }
  
  func flatMap<Mapped>(_ transform: @escaping (Parsed) -> Parser<Mapped>) -> Parser<Mapped> {
    return Parser<Mapped> { [parse] stream in
      parse(stream).flatMap { parsed, remaining in transform(parsed).parse(remaining) }
    }
  }
}

func <^> <Parsed, Mapped>(transform: @escaping (Parsed) -> Mapped, parser: Parser<Parsed>) -> Parser<Mapped> {
  return parser.map(transform)
}

func <*> <Parsed, Mapped>(transform: Parser<(Parsed) -> Mapped>, parser: @autoclosure @escaping () -> Parser<Parsed>) -> Parser<Mapped> {
  return Parser<Mapped> { stream in
    guard let (transform, remaining0) = transform.parse(stream) else { return nil }
    guard let (parsed, remaining1) = parser().parse(remaining0) else { return nil }
    return (transform(parsed), remaining1)
  }
}

func ?? <Parsed>(left: Parser<Parsed>, right: @autoclosure @escaping () -> Parser<Parsed>) -> Parser<Parsed> {
  return Parser { stream in left.parse(stream) ?? right().parse(stream) }
}

enum Parse {
  
  static let character = Parser<Character> { $0.decomposed }
  
  static func satisfying(_ predicate: @escaping (Character) -> Bool) -> Parser<Character> {
    return character.flatMap { character in
      predicate(character) ? Parser(character) : Parser()
    }
  }
  
  static func character(matching char: Character) -> Parser<Character> {
    return satisfying { ch in char == ch }
  }
  
  static let lowercase = satisfying { ch in "a" <= ch && ch <= "z" }
  
  static let uppercase = satisfying { ch in "A" <= ch && ch <= "Z" }
  
  static let letter = lowercase ?? uppercase
  
  static func string(matching match: String) -> Parser<String> {
    return Parser { stream in
      var stream = stream
      let charParser = satisfying { _ in true }
      var chars = Substring(match)
      while let (head, tail) = chars.decomposed {
        guard let (parsed, remaining) = charParser.parse(stream), head == parsed else { return nil }
        chars = tail
        stream = remaining
      }
      return (match, stream)
    }
  }
  
  static func bracket<Open, Parsed, Close>(open: Parser<Open>, parser: Parser<Parsed>, close: Parser<Close>) -> Parser<Parsed> {
    return curried { _, parsed, _ in parsed } <^> open <*> parser <*> close
  }
}

private extension Collection where SubSequence == Self {
  var decomposed: (Iterator.Element, SubSequence)? {
    return first.map { ($0, dropFirst()) }
  }
}
