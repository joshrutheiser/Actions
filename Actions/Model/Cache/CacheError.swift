//
//  CacheError.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/4/23.
//

import Foundation

enum CacheError: Error {
    case NoRemoveActionsNil(_ actionId: String?)
}
