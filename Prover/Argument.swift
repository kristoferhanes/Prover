//
//  Argument.swift
//  TruthTree
//
//  Created by Kristofer Hanes on 2015 12 01.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import Foundation

struct Argument {
  var premises: [Proposition]
  var conclusion: Proposition

  var isValid: Bool {
    let tree = TruthTree(premises + [~conclusion])
    return !tree.isConsistent
  }
}
