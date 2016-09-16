//
//  TruthTree.swift
//  TruthTree
//
//  Created by Kristofer Hanes on 2015 12 01.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import Foundation

struct TruthTree {

  var props: [Prop]
  var children: Children

  indirect enum Children {
    case some(TruthTree, TruthTree)
    case none
  }

  init(_ props: [Prop]) {

    func trunkRule(_ prop: Prop) -> [Prop] {
      switch prop {
      case let .conj(left, right): return [left, right]
      case let .neg(.impl(ant, cons)): return [ant, ~cons]
      case let .neg(.disj(left, right)): return [~left, ~right]
      case let .neg(.neg(p)): return [p]
      default: return []
      }
    }

    func branchRule(_ prop: Prop) -> ([Prop], [Prop])? {
      switch prop {
      case let .impl(ant, cons): return ([~ant], [cons])
      case let .disj(left, right): return ([left], [right])
      case let .neg(.conj(left, right)): return ([~left], [~right])
      case let .eqiv(left, right): return ([left, right], [~left, ~right])
      case let .neg(.eqiv(left, right)): return ([~left, right], [left, ~right])
      default: return nil
      }
    }

    func trunkProps(_ props: [Prop]) -> [Prop] {
      guard !props.isEmpty else { return [] }
      let newProps = props.flatMap(trunkRule)
      return props + trunkProps(newProps)
    }

    func branchProps(_ props: [Prop]) -> (left: [Prop], right: [Prop])? {
      let newProps = props.flatMap(branchRule)
      guard !newProps.isEmpty else { return nil }
      let left = newProps.flatMap { l, _ in l }
      let right = newProps.flatMap { _, r in r }
      return (left, right)
    }

    self.props = trunkProps(props)
    self.children = branchProps(self.props).map { .some(TruthTree($0), TruthTree($1)) } ?? .none
  }

  var isConsistent: Bool {

    func areConsistent(_ props: Set<Prop>) -> Bool {
      for p in props {
        if props.contains(~p) { return false }
      }
      return true
    }

    func isConsistent(_ tree: TruthTree, _ props: Set<Prop>) -> Bool {
      let props = props.union(tree.props)
      guard case let .some(left, right) = tree.children else { return areConsistent(props) }
      return isConsistent(left, props) || isConsistent(right, props)
    }

    return isConsistent(self, [])
  }
  
}
