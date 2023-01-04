//
//  ModelController+Errors.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/4/23.
//

import Foundation

extension ModelController {
    enum Errors: Error {
        case UserNotLoaded
        case RankOutOfBounds(_ parentId: String, _ count: Int, _ rank: Int)
        case ActionMissing(_ id: String)
    }
}
