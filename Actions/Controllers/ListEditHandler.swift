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
    
    func handleEditEvent(
        _ actionId: String,
        _ event: EditEvent)
    {
        print("Action: \(actionId), Event: \(event)")

        switch event {
        case .Tapped:
            stopEditing()
            editingId = actionId
        case .Backspace:
            return
        case .Enter(let text, let index):
            enter(actionId, text, index)
        case .Save(let text):
            save(actionId, text)
        case .Complete:
            complete(actionId)
        case .Modify:
            DispatchQueue.main.async {
                self.tableView.updateHeight()
            }
        }
    }
    
    //MARK: - Stop
    
    func stopEditing() {
        guard let editingId = editingId else { return }
        guard let cell = getCell(editingId) else { return }
        let text = cell.getText()
        cell.stopEditing()
        
        // delete if text is empty
        if text.isEmpty {
            remove(editingId)
        }
        
        self.editingId = nil
    }
    
    //MARK: - Start
    // note that editing id must be set in calling function
    // this is done to enable a workaround solution to the
    // keyboard animation glitch
    
    func startEditing(_ actionId: String, _ index: Int) {
        guard let cell = getCell(actionId) else { return }
        cell.startEditing(index)
    }
    
    //MARK: - Complete
    
    private func complete(_ actionId: String) {
        try? model.write.completeAction(actionId)
        removeRow(actionId)
    }
    
    //MARK: - Remove
    
    private func remove(_ actionId: String) {
        try? model.write.deleteAction(actionId)
        removeRow(actionId)
    }
    
    //MARK: - Save
    
    private func save(
        _ actionId: String,
        _ text: String)
    {
        try? model.write.saveActionText(actionId, text)
    }
    
    //MARK: - Enter
    
    private func enter(
        _ actionId: String,
        _ text: String,
        _ index: Int)
    {
        // do all guards first before making changes so
        // things stay the same if there is an error
        // rather than the alternative of losing data
        guard let rank = getRow(actionId) else { return }
        guard let cell = getCell(actionId) else { return }
        let (first, second) = text.split(index)
        guard let newId = try? model.write.createAction(
            second.trim(), rank: rank + 1
        ) else { return }
        
        // stop editing must be called after start to
        // avoid keyboard animation glitch
        cell.setText(first.trim())
        save(actionId, first.trim())
        tableView.addRow(rank + 1)
        startEditing(newId, 0)
        stopEditing()
        editingId = newId
    }
}

//MARK: - Helper functions

extension ListEditHandler {
    
    //MARK: - Remove row
    
    private func removeRow(_ actionId: String) {
        DispatchQueue.main.async {
            guard let rank = self.getRow(actionId) else { return }
            self.tableView.removeRow(rank)
        }
    }
    
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
    
    //MARK: - Get row
    
    #warning ("TODO: create dictionary of actionid and row as part of data source")
    
    private func getRow(_ actionId: String) -> Int? {
        let count = tableView.numberOfRows(inSection: 0)
        
        for i in 0..<count {
            guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ActionCell else { continue }
            
            if cell.id == actionId {
                return i
            }
        }
        
        return nil
    }
}
