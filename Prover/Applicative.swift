//
//  Applicative.swift
//  Prover
//
//  Created by Kristofer Hanes on 11/20/16.
//  Copyright © 2016 Kristofer Hanes. All rights reserved.
//

precedencegroup ApplicativePrecedence {
  associativity: left
  lowerThan: AssignmentPrecedence
}

infix operator <^> : ApplicativePrecedence
infix operator <*> : ApplicativePrecedence
