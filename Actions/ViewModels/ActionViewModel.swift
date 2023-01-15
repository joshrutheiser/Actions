//
//  ActionViewModel.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/14/23.
//

import Foundation

class ActionViewModel {
    private let model: ModelController
    private var action: Action
    
    init(_ model: ModelController, _ action: Action) {
        self.model = model
        self.action = action
    }
    
    
}
