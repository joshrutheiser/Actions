//
//  ModelError.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/4/23.
//

import Foundation

//MARK: - ModelError

enum ModelError: Error {
    case UserNotLoaded
    case RankOutOfBounds(_ parentId: String, _ count: Int, _ rank: Int)
    case ActionMissing(_ id: String)
    case ActionHasNoParent(_ id: String)
    case InvalidModeSet(_ mode: String)
    case BacklogNotFound(_ mode: String)
}
