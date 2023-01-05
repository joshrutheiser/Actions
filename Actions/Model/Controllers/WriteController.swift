//
//  WriteController.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/4/23.
//

import Foundation

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
    // if parentId is nil, add to backlog

    func createAction(
        _ text: String,
        parentId: String? = nil,
        rank: Int = 0) async throws -> String?
    {
        let action = Action(text, parentId)
        let actionId = try await dataSync.createAction(action)
        try await insert(actionId, into: parentId, at: rank)
        try await dataSync.commit()
        return actionId
    }
    
    //MARK: - Move action
    // parentId of nil == backlog
    
    func moveActionTo(
        _ actionId: String,
        parentId: String?,
        rank: Int = 0) async throws
    {
        try await remove(child: actionId)
        try await insert(actionId, into: parentId, at: rank)
        var action = try await read.getAction(actionId)
        action.parentId = parentId
        try await dataSync.updateAction(action)
        try await dataSync.commit()
    }
    
    // Move within parent
    
    func moveAction(
        _ actionId: String,
        rank: Int = 0) async throws
    {
        let parentId = try await read.getParentId(actionId)
        try await moveActionTo(actionId, parentId: parentId, rank: rank)
    }
    
    //MARK: - Complete action
    
    func completeAction(_ actionId: String) async throws
    {
//        try await remove(actionId)
//        var action = try await read.getAction(actionId)
    }
    
    //MARK: - Delete action
    
    func deleteAction(_ actionId: String) async throws
    {

    }
    
    //MARK: - Save action text
    
    func saveActionText(
        _ actionId: String,
        _ text: String) async throws
    {
            
    }
    
    #warning ("TODO: decide if I should remove the today list in favor of just pulling in the top X items")
    
    //MARK: - Set today
    
    func setToday(_ actionIds: [String]) async throws
    {
            
    }
    
    //MARK: - Add today
    
    func addToday(
        _ actionId: String,
        _ rank: Int = 0) async throws
    {
        
    }
    
    //MARK: - Remove today
    
    func removeToday(_ actionId: String) async throws
    {
        
    }
    
    //MARK: - Toggle mode
    
    func toggleMode() async throws {
        
    }
    
    //MARK: - Skip
    
    func skip(_ actionId: String) async throws
    {
        
    }
    
    
    //MARK: - Set schedule
    
    func setSchedule(
        _ actionId: String,
        _ schedule: Date) async throws
    {
        
    }
    
}

//MARK: - Private functions

extension WriteController {
    
    //MARK: - Insert
    
    private func insert(
        _ actionId: String,
        into parentId: String?,
        at rank: Int) async throws
    {
        if parentId == nil {
            try await backlogInsert(actionId, rank)
        } else {
            try await parentInsert(actionId, parentId!, rank)
        }
    }
        
    private func backlogInsert(
        _ actionId: String,
        _ rank: Int) async throws
    {
        var user = try await read.getUser()
        let mode = user.currentMode
        if var backlog = user.backlog[mode] {
            try checkArrayBounds(K.Title.backlog, backlog, rank)
            backlog.insert(actionId, at: rank)
            user.backlog[mode] = backlog
        } else {
            try checkArrayBounds(K.Title.backlog, [], rank)
            user.backlog[mode] = [actionId]
        }
        try await dataSync.updateUser(user)
    }
    
    private func parentInsert(
        _ actionId: String,
        _ parentId: String,
        _ rank: Int) async throws
    {
        var parent = try await read.getAction(parentId)
        try checkArrayBounds(parentId, parent.childIds, rank)
        parent.childIds.insert(actionId, at: rank)
        try await dataSync.updateAction(parent)
    }
    
    //MARK: - Remove
    
    private func remove(
        child actionId: String) async throws
    {
        let action = try await read.getAction(actionId)
        if action.parentId == nil {
            try await backlogRemove(actionId)
        } else {
            try await parentRemove(actionId)
        }
    }
    
    private func backlogRemove(
        _ actionId: String) async throws
    {
        var user = try await read.getUser()
        let mode = user.currentMode
        if var backlog = user.backlog[mode] {
            backlog.removeAll(where: { $0 == actionId })
            user.backlog[mode] = backlog
        } else {
            user.backlog[mode] = []
        }
        try await dataSync.updateUser(user)
    }
    
    private func parentRemove(
        _ actionId: String) async throws
    {
        var parent = try await read.getParent(actionId)
        parent.childIds.removeAll(where: {$0 == actionId})
        try await dataSync.updateAction(parent)
    }
    
    //MARK: - Bound check
    
    private func checkArrayBounds(
        _ parent: String,
        _ ids: [String],
        _ rank: Int) throws
    {
        let count = ids.count + 1
        guard rank < count else {
            throw Errors.RankOutOfBounds(parent, count, rank)
        }
    }
    
}
