//
//  ListEditHandler.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/15/23.
//

import Foundation
import UIKit

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

        DispatchQueue.main.async {
            switch event {
            case .Tapped:
                self.stopEditing()
                self.editingId = actionId
            case .Backspace(let text):
                self.backspace(actionId, text)
            case .Enter(let text, let index):
                self.enter(actionId, text, index)
            case .Save(let text):
                self.save(actionId, text)
            case .Complete:
                self.complete(actionId)
            case .Modify:
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
        guard let rank = getRank(actionId) else { return }
        try? model.write.completeAction(actionId)
        tableView.removeRow(rank)
    }
    
    //MARK: - Remove
    
    private func remove(_ actionId: String) {
        guard let rank = getRank(actionId) else { return }
        try? model.write.deleteAction(actionId)
        tableView.removeRow(rank)
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
        guard let rank = getRank(actionId) else { return }
        guard let cell = getCell(rank) else { return }
        let (first, second) = text.split(index)
        guard let newId = try? model.write.createAction(
            second.trim(), rank: rank + 1
        ) else { return }
        
        #warning ("TODO: implement functionality for pressing enter at beginning of text")
        // stop editing must be called after start to
        // avoid keyboard animation glitch
        cell.setText(first.trim())
        save(actionId, first.trim())
        tableView.addRow(rank + 1)
        startEditing(newId, 0)
        stopEditing()
        editingId = newId
    }
    
    //MARK: - Backspace
    
    private func backspace(
        _ actionId: String,
        _ text: String)
    {
        // do all guards first before making changes so
        // things stay the same if there is an error
        // rather than the alternative of losing data
        guard let rank = getRank(actionId) else { return }
        guard rank > 0 else { return }
        guard let previous = getCell(rank - 1) else { return }
        guard let prevId = previous.id else { return }
        
        let prevText = previous.getText()
        let newText = prevText + text.trim()
        let index = prevText.count
        
        // stop editing must be called after start to
        // avoid keyboard animation glitch
        previous.setText(newText)
        save(prevId, newText)
        startEditing(prevId, index)
        stopEditing()
        remove(actionId)
        editingId = prevId
    }
}

//MARK: - Helper functions

extension ListEditHandler {
    
    //MARK: - Get cell
    
    private func getCell(_ actionId: String) -> ActionCell? {
        guard let rank = getRank(actionId) else { return nil }
        return getCell(rank)
    }

    private func getCell(_ rank: Int) -> ActionCell? {
        // try and get the cell if it is visibile or in cache
        // if not, then get it from the data source directly
        let indexPath = IndexPath(row: rank, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ActionCell {
            return cell
        }
        guard let data = tableView.dataSource as? DataSource else { return nil }
        return data.tableView(tableView, cellForRowAt: indexPath) as? ActionCell
    }
    
    //MARK: - Get rank
    
    private func getRank(_ actionId: String) -> Int? {
        guard let data = tableView.dataSource as? DataSource else { return nil }
        return data.ids.firstIndex(of: actionId)
    }
}
