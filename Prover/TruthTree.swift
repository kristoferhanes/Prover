//
//  TruthTree.swift
//  TruthTree
//
//  Created by Kristofer Hanes on 2015 12 01.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import Foundation

struct TruthTree {

  var props: [Proposition]
  var children: Children

  indirect enum Children {
    case some(TruthTree, TruthTree)
    case none
  }

  init(_ props: [Proposition]) {

    func trunkRule(_ prop: Proposition) -> [Proposition] {
      switch prop {
      case let .conjunction(left, right): return [left, right]
      case let .negation(.implication(ant, cons)): return [ant, ~cons]
      case let .negation(.disjunction(left, right)): return [~left, ~right]
      case let .negation(.negation(p)): return [p]
      default: return []
      }
    }

    func branchRule(_ prop: Proposition) -> ([Proposition], [Proposition])? {
      switch prop {
      case let .implication(ant, cons): return ([~ant], [cons])
      case let .disjunction(left, right): return ([left], [right])
      case let .negation(.conjunction(left, right)): return ([~left], [~right])
      case let .eqivalence(left, right): return ([left, right], [~left, ~right])
      case let .negation(.eqivalence(left, right)): return ([~left, right], [left, ~right])
      default: return nil
      }
    }

    func trunkProps(_ props: [Proposition]) -> [Proposition] {
      guard !props.isEmpty else { return [] }
      let newProps = props.flatMap(trunkRule)
      return props + trunkProps(newProps)
    }

    func branchProps(_ props: [Proposition]) -> (left: [Proposition], right: [Proposition])? {
      let newProps = props.compactMap(branchRule)
      guard !newProps.isEmpty else { return nil }
      let left = newProps.flatMap { l, _ in l }
      let right = newProps.flatMap { _, r in r }
      return (left, right)
    }

    self.props = trunkProps(props)
    self.children = branchProps(self.props).map { .some(TruthTree($0), TruthTree($1)) } ?? .none
  }

  var isConsistent: Bool {

    func areConsistent(_ props: Set<Proposition>) -> Bool {
      for p in props {
        if props.contains(~p) { return false }
      }
      return true
    }

    func isConsistent(_ tree: TruthTree, _ props: Set<Proposition>) -> Bool {
      let props = props.union(tree.props)
      guard case let .some(left, right) = tree.children else { return areConsistent(props) }
      return isConsistent(left, props) || isConsistent(right, props)
    }

    return isConsistent(self, [])
  }
  
}
