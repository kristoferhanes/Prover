//
//  Parser.swift
//  Parser
//
//  Created by Kristofer Hanes on 2015 11 10.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import Foundation

private extension String {
  var first: Character? {
    return characters.first
  }

  func dropFirst() -> String {
    return String(characters.dropFirst())
  }

  var decompose: (Character, String)? {
    return first.map { ($0, dropFirst()) }
  }
}

struct Parser<Result> {
  private let operation: String->(Result, String)?

  init(_ operation: String->(Result, String)?) {
    self.operation = operation
  }

  init(_ result: Result) {
    self.init { input in (result, input) }
  }

  init() {
    self.init { _ in nil }
  }

  func parse(input: String) -> (result: Result, remaining: String)? {
    return operation(input)
  }

  func map<U>(transform: Result->U) -> Parser<U> {
    return Parser<U> { input in self.parse(input).map { v, rem in
      (transform(v), rem) } }
  }

  func flatMap<U>(transform: Result->Parser<U>) -> Parser<U> {
    return Parser<U> { input in
      self.parse(input).flatMap { v, rem in transform(v).parse(rem) }
    }
  }

}

func product<A,B>(a: Parser<A>,
  @autoclosure(escaping) _ b: ()->Parser<B>) -> Parser<(A,B)> {
    return a.flatMap { a in b().map { b in (a, b) } }
}

func product<A,B,C>(a: Parser<A>,
  @autoclosure(escaping) _ b: ()->Parser<B>,
  @autoclosure(escaping) _ c: ()->Parser<C>) -> Parser<(A,B,C)> {
    return a.flatMap { a in b().flatMap { b in c().map { c in (a, b, c) } } }
}

func product<A,B,C,D>(a: Parser<A>,
  @autoclosure(escaping) _ b: ()->Parser<B>,
  @autoclosure(escaping) _ c: ()->Parser<C>,
  @autoclosure(escaping) _ d: ()->Parser<D>) -> Parser<(A,B,C,D)> {
    return a.flatMap { a in b().flatMap { b in c().flatMap { c in
      d().map { d in (a, b, c, d) } } } }
}

func product<A,B,C,D,E>(a: Parser<A>,
  @autoclosure(escaping) _ b: ()->Parser<B>,
  @autoclosure(escaping) _ c: ()->Parser<C>,
  @autoclosure(escaping) _ d: ()->Parser<D>,
  @autoclosure(escaping) _ e: ()->Parser<E>) -> Parser<(A,B,C,D,E)> {
    return a.flatMap { a in b().flatMap { b in c().flatMap { c in
      d().flatMap { d in e().map { e in (a, b, c, d, e) } } } } }
}

func itemParser() -> Parser<Character> {
  return Parser<Character> { input in
    let chars = input.characters
    return chars.first.map { ($0, String(chars.dropFirst())) }
  }
}

func satisfyParser(predicate: Character->Bool) -> Parser<Character> {
  return itemParser().flatMap { character in
    predicate(character) ? Parser(character) : Parser()
  }
}

func characterParser(character: Character) -> Parser<Character> {
  return satisfyParser { ch in character == ch }
}

func digitParser() -> Parser<Character> {
  return satisfyParser { ch in "0" <= ch && ch <= "9" }
}

func lowercaseCharacterParser() -> Parser<Character> {
  return satisfyParser { ch in "a" <= ch && ch <= "z" }
}

func uppercaseCharacterParser() -> Parser<Character> {
  return satisfyParser { ch in "A" <= ch && ch <= "Z" }
}

func ?? <T>(lhs: Parser<T>, @autoclosure(escaping) rhs: ()->Parser<T>) -> Parser<T> {
  return Parser { input in lhs.parse(input) ?? rhs().parse(input) }
}

func letterParser() -> Parser<Character> {
  return lowercaseCharacterParser() ?? uppercaseCharacterParser()
}

func alphaNumericParser() -> Parser<Character> {
  return letterParser() ?? digitParser()
}

func wordParser() -> Parser<String> {
  return product(letterParser(), wordParser()).flatMap { Parser("\($0)" + $1) }
    ?? Parser("")
}

func stringParser(string: String) -> Parser<String> {
  guard let (x, xs) = string.decompose else { return Parser("") }
  return product(characterParser(x), stringParser(xs))
    .flatMap { Parser("\($0)" + $1 ) }
}

func manyParser(parser: Parser<Character>) -> Parser<String> {
  return product(parser, manyParser(parser)).flatMap { Parser("\($0)" + $1) }
    ?? Parser("")
}

func manyParser<T>(parser: Parser<T>) -> Parser<[T]> {
  return product(parser, manyParser(parser)).flatMap { Parser([$0] + $1) }
    ?? Parser([])
}

func identifierParser() -> Parser<String> {
  return product(lowercaseCharacterParser(), manyParser(alphaNumericParser()))
    .flatMap { Parser("\($0)" + $1) }
}

func many1Parser(parser: Parser<Character>) -> Parser<String> {
  return product(parser, manyParser(parser)).flatMap { Parser("\($0)" + $1) }
}

func many1Parser<T>(parser: Parser<T>) -> Parser<[T]> {
  return product(parser, manyParser(parser)).flatMap { Parser([$0] + $1) }
}

private extension Character {
  var unicodeValue: UInt32 {
    return String(self).unicodeScalars.first!.value
  }
}

func naturalNumberParser() -> Parser<Int> {
  let op: (Int, Int)->Int = { m, n in 10*m + n }
  return chainL1Parser(digitParser().flatMap { x in
    Parser(Int(x.unicodeValue - Character("0").unicodeValue))
    }, operation: Parser(op))
}

func integerParser() -> Parser<Int> {
  return product(characterParser("-"), naturalNumberParser())
    .flatMap { Parser(-$1) } ?? naturalNumberParser()
}

func separateBy1Parser<A,B>(parser: Parser<A>, separator: Parser<B>) -> Parser<[A]> {
  return product(parser, manyParser(product(separator, parser).map { _, y in y }))
    .map { x, xs in [x] + xs }
}

func separateByParser<A,B>(parser: Parser<A>, separator: Parser<B>) -> Parser<[A]> {
  return separateBy1Parser(parser, separator: separator) ?? Parser([])
}

func bracketParser<A,B,C>(open open: Parser<A>, parser: Parser<B>,
  close: Parser<C>) -> Parser<B> {
    return product(open, parser, close).map { _, x, _ in x }
}

func integersParser() -> Parser<[Int]> {
  return bracketParser(
    open: characterParser("["),
    parser: separateBy1Parser(integerParser(), separator: characterParser(",")),
    close: characterParser("]"))
}

func chainL1Parser<T>(parser: Parser<T>, operation: Parser<(T,T)->T>) -> Parser<T> {
  return product(parser, manyParser(product(operation, parser).map { f, y in (f, y) }))
    .map { x, fys in fys.reduce(x) { accum, z in let (f, y) = z; return f(accum, y) }
  }
}

func chainR1Parser<T>(parser: Parser<T>, operation: Parser<(T,T)->T>) -> Parser<T> {
  return parser.flatMap { x in product(operation,
    chainR1Parser(parser, operation: operation)).map { f, y in f(x, y) } }
}

private extension Array {
  func reduce(combine: (Element, Element)->Element) -> Element {
    return dropFirst().reduce(first!, combine: combine)
  }

  func reduceFromLast(combine: (Element, Element)->Element) -> Element {
    return reverse().reduce { accum, x in combine(x, accum) }
  }
}

func operatorsParser<A,B>(parsers: [(Parser<A>, B)]) -> Parser<B> {
  return parsers.map { p, op in p.map { _ in op } }
    .reduceFromLast { x, accum in accum ?? x }
}
