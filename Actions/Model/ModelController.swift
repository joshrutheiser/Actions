//
//  ModelController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation

// to do - diffable objects, only update actions that were changed instead of all

class ModelController {
    private let listeners = Listeners()
    
    private var user: User? {
        didSet { print("user updated!") }
    }
    
    private var actions: [String: Action] = [:] {
        didSet { print("actions updated!"); print("\(actions)") }
    }
    
    init() {
        listeners.startActions { [weak self] data in
            if let data = data {
                self?.actions = data
            }
        }
    }
    
    deinit {
        listeners.stopActions()
    }
}
