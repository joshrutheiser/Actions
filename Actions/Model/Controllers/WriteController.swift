//
//  WriteController.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/4/23.
//

import Foundation
#warning ("TODO: figure out how to handle database write errors")
class WriteController {
    private let dataSync: DataSync
    private let read: ReadController
    
    init(_ dataSync: DataSync,
         _ read: ReadController)
    {
        self.dataSync = dataSync
        self.read = read
    }
    
    //MARK: - Create action
    // parentId of nil == backlog
    
    func createAction(
        _ text: String,
        parentId: String? = nil,
        rank: Int = 0) throws -> String?
    {
        let action = Action(text, parentId)
        let actionId = try dataSync.createAction(action)
        try insert(actionId, into: parentId, at: rank)
        try dataSync.commit()
        return actionId
    }
    
    //MARK: - Move action
    // parentId of nil == backlog
    
    func moveActionTo(
        _ actionId: String,
        parentId: String?,
        rank: Int = 0) throws
    {
        try remove(child: actionId)
        try insert(actionId, into: parentId, at: rank)
        var action = try read.getAction(actionId)
        action.parentId = parentId
        try dataSync.updateAction(action)
        try dataSync.commit()
    }
    
    // Move within parent
    
    func moveAction(
        _ actionId: String,
        rank: Int = 0) throws
    {
        let parentId = try read.getParentId(actionId)
        try moveActionTo(actionId, parentId: parentId, rank: rank)
    }
    
    //MARK: - Complete action
    // Don't remove from cache in case user wants to undo
    
    func completeAction(_ actionId: String) throws
    {
        try remove(child: actionId)
        try setComplete(actionId)
        let childIds = try read.getChildActionIds(actionId)
        for id in childIds {
            try setComplete(id)
        }
        try dataSync.commit()
    }
    
    //MARK: - Delete action
    
    func deleteAction(_ actionId: String) throws
    {
        try remove(child: actionId)
        try setDelete(actionId)
        let childIds = try read.getChildActionIds(actionId)
        for id in childIds {
            try setDelete(id)
        }
        try dataSync.commit()
    }
    
    //MARK: - Save action text
    
    func saveActionText(
        _ actionId: String,
        _ text: String) throws
    {
        var action = try read.getAction(actionId)
        action.text = text
        try dataSync.updateAction(action)
        try dataSync.commit(notify: false)
    }
    
    //MARK: - Toggle mode
    
    func toggleMode() throws {
        var user = try read.getUser()
        guard let mode = Mode.init(rawValue: user.currentMode) else {
            throw ModelError.InvalidModeSet(user.currentMode)
        }
        switch mode {
            case .Personal: user.currentMode = Mode.Work.rawValue
            case .Work: user.currentMode = Mode.Personal.rawValue
        }
        try dataSync.updateUser(user)
        try dataSync.commit()
    }
    
    //MARK: - Skip
    
    func skip(_ actionId: String) throws
    {
        var action = try read.getAction(actionId)
        action.skipped += 1
        action.lastSkipped = Date()
        try dataSync.updateAction(action)
        try dataSync.commit()
    }
    
    
    //MARK: - Schedule
    
    func schedule(
        _ actionId: String,
        _ schedule: Date) throws
    {
        var action = try read.getAction(actionId)
        action.scheduledDate = schedule
        try dataSync.updateAction(action)
        try dataSync.commit()
    }
    
}

//MARK: - Private functions
// note that none of these private functions call commit()

extension WriteController {
    
    //MARK: - Insert
    
    private func insert(
        _ actionId: String,
        into parentId: String?,
        at rank: Int) throws
    {
        if parentId == nil {
            try backlogInsert(actionId, at: rank)
        } else {
            try parentInsert(actionId, into: parentId!, at: rank)
        }
    }
        
    private func backlogInsert(
        _ actionId: String,
        at rank: Int) throws
    {
        var user = try read.getUser()
        let mode = user.currentMode
        if var backlog = user.backlog[mode] {
            try checkArrayBounds(K.Title.backlog, backlog, rank)
            backlog.insert(actionId, at: rank)
            user.backlog[mode] = backlog
        } else {
            try checkArrayBounds(K.Title.backlog, [], rank)
            user.backlog[mode] = [actionId]
        }
        try dataSync.updateUser(user)
    }
    
    private func parentInsert(
        _ actionId: String,
        into parentId: String,
        at rank: Int) throws
    {
        var parent = try read.getAction(parentId)
        try checkArrayBounds(parentId, parent.childIds, rank)
        parent.childIds.insert(actionId, at: rank)
        try dataSync.updateAction(parent)
    }
    
    //MARK: - Remove
    
    private func remove(
        child actionId: String) throws
    {
        let action = try read.getAction(actionId)
        if action.parentId == nil {
            try backlogRemove(child: actionId)
        } else {
            try parentRemove(child: actionId)
        }
    }
    
    private func backlogRemove(
        child actionId: String) throws
    {
        var user = try read.getUser()
        let mode = user.currentMode
        if var backlog = user.backlog[mode] {
            backlog.removeAll(where: { $0 == actionId })
            user.backlog[mode] = backlog
        } else {
            user.backlog[mode] = []
        }
        try dataSync.updateUser(user)
    }
    
    private func parentRemove(
        child actionId: String) throws
    {
        var parent = try read.getParent(actionId)
        parent.childIds.removeAll(where: {$0 == actionId})
        try dataSync.updateAction(parent)
    }
    
    //MARK: - Complete
    
    private func setComplete(
        _ actionId: String) throws
    {
        var action = try read.getAction(actionId)
        action.isCompleted = true
        action.completedDate = Date()
        try dataSync.updateAction(action)
    }
    
    //MARK: - Delete
    
    private func setDelete(
        _ actionId: String) throws
    {
        var action = try read.getAction(actionId)
        action.isDeleted = true
        action.deletedDate = Date()
        try dataSync.updateAction(action)
    }
    
    //MARK: - Bound check
    
    private func checkArrayBounds(
        _ parent: String,
        _ ids: [String],
        _ rank: Int) throws
    {
        let count = ids.count + 1
        guard rank < count else {
            throw ModelError.RankOutOfBounds(parent, count, rank)
        }
    }
    
}
