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
    case Some(TruthTree, TruthTree)
    case None
  }

  init(_ props: [Prop]) {

    func trunkRule(prop: Prop) -> [Prop] {
      switch prop {
      case let .Conj(left, right): return [left, right]
      case let .Neg(.Impl(ant, cons)): return [ant, ~cons]
      case let .Neg(.Disj(left, right)): return [~left, ~right]
      case let .Neg(.Neg(p)): return [p]
      default: return []
      }
    }

    func branchRule(prop: Prop) -> ([Prop], [Prop])? {
      switch prop {
      case let .Impl(ant, cons): return ([~ant], [cons])
      case let .Disj(left, right): return ([left], [right])
      case let .Neg(.Conj(left, right)): return ([~left], [~right])
      case let .Eqiv(left, right): return ([left, right], [~left, ~right])
      case let .Neg(.Eqiv(left, right)): return ([~left, right], [left, ~right])
      default: return nil
      }
    }

    func trunkProps(props: [Prop]) -> [Prop] {
      guard !props.isEmpty else { return [] }
      let newProps = props.flatMap(trunkRule)
      return props + trunkProps(newProps)
    }

    func branchProps(props: [Prop]) -> (left: [Prop], right: [Prop])? {
      let newProps = props.flatMap(branchRule)
      guard !newProps.isEmpty else { return nil }
      let left = newProps.flatMap { l, _ in l }
      let right = newProps.flatMap { _, r in r }
      return (left, right)
    }

    self.props = trunkProps(props)
    if let (left, right) = branchProps(self.props) {
      children = .Some(TruthTree(left), TruthTree(right))
    } else {
      children = .None
    }
  }

  var isConsistent: Bool {

    func areConsistent(props: Set<Prop>) -> Bool {
      for p in props {
        if props.contains(~p) { return false }
      }
      return true
    }

    func isConsistent(tree: TruthTree, _ props: Set<Prop>) -> Bool {
      let props = props.union(tree.props)
      guard case let .Some(left, right) = tree.children else { return areConsistent(props) }
      return isConsistent(left, props) || isConsistent(right, props)
    }

    return isConsistent(self, [])
  }
  
}
