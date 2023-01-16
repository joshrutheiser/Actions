//
//  ListEditHandler.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/15/23.
//

import Foundation
import UIKit

/*
 
 Responsibility = handle edit events
 
 */

class ListEditHandler {
    private let model: ModelController
    private let tableView: UITableView
    private var editingId: String?
    
    init(_ model: ModelController, _ tableView: UITableView) {
        self.model = model
        self.tableView = tableView
    }
}

//MARK: - Handle events

extension ListEditHandler: ActionCellDelegate {
    func handleEditEvent(_ actionId: String, _ event: EditEvent) {
        print("Action: \(actionId), Event: \(event)")

        switch event {
        case .Tapped:
            stopEditing()
            editingId = actionId
        case .Backspace:
            return
        case .Enter(_):
            return
        case .Save(let text):
            Task {
                try await self.model.write.saveActionText(actionId, text)
            }
        case .Complete:
            Task {
                try await self.model.write.completeAction(actionId)
            }
        case .Modify:
            DispatchQueue.main.async {
                self.tableView.updateHeight()
            }
        }
    }
}

//MARK: - Start and stop

extension ListEditHandler {
    
    func stopEditing() {
        guard let editingId = editingId else { return }
        guard let cell = getCell(editingId) else { return }
        let text = cell.getText()
        cell.stopEditing()
        
        // delete if text is empty
        if text.isEmpty {
            Task {
                try await self.model.write.deleteAction(editingId)
                self.editingId = nil
            }
        }
    }
    
    func startEditing(_ actionId: String, _ index: Int) {
        
    }
}

//MARK: - Private functions

extension ListEditHandler {
    
    //MARK: - Get cell
    
    private func getCell(_ actionId: String) -> ActionCell? {
        let count = tableView.numberOfRows(inSection: 0)
        
        for i in 0..<count {
            guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ActionCell else { continue }
            
            if cell.id == actionId {
                return cell
            }
        }
        
        return nil
    }
}
