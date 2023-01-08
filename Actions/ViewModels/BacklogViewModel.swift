//
//  BacklogViewModel.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/7/23.
//

import Foundation

class BacklogViewModel {
    private let model: ModelController
    private var data = [Action]()
    
    var write: WriteController { model.write }
    var count: Int { data.count }
    
    subscript(index: Int) -> Action {
        get { data[index] }
    }
    
    init(_ model: ModelController) {
        self.model = model
    }
    
    func reload() throws {
        data = []
        guard model.read.isUserSet() else { return }
        guard model.read.isActionsSet() else { return }
        let backlogIds = try model.read.getBacklog()
        data = try backlogIds.map({ try model.read.getAction($0) })
    }
}

