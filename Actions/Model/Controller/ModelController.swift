//
//  ModelController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/31/22.
//

import Foundation

class ModelController {
    var dataSync: DataSync

    init(_ config: DataSyncConfig) {
        self.dataSync = DataSync(config)
    }
    
    convenience init(
        _ userId: String,
        _ delegate: LocalCacheDelegate)
    {
        let config = DataSyncConfig(
            databaseWriter: DatabaseWriter(),
            databaseReader: DatabaseReader(),
            cache: LocalCache(delegate),
            session: UUID().uuidString,
            userId: userId
        )
        self.init(config)
    }
    
    func load() async throws {
        try await dataSync.listen()
    }
}

//MARK: - Model Controller

extension ModelController {
    
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
    
    //MARK: - Create action
    // if parentId is nil, add to backlog

    func createAction(
        _ text: String,
        parentId: String? = nil,
        rank: Int = 0) async throws -> String?
    {
        var user = try await getUser()
        let action = Action(user.userId, text, parentId)
        let actionId = try await dataSync.createAction(action)
        
        if let parentId = parentId {
            // add to parent action
            var parent = try await getAction(parentId)
            try checkArrayBounds(parentId, parent.childIds, rank)
            parent.childIds.insert(actionId, at: rank)
            try await dataSync.updateAction(parent)
        } else {
            // add to backlog
            let mode = user.currentMode
            if var backlog = user.backlog[mode] {
                try checkArrayBounds("backlog", backlog, rank)
                backlog.insert(actionId, at: rank)
                user.backlog[mode] = backlog
            } else {
                try checkArrayBounds("backlog", [], rank)
                user.backlog[mode] = [actionId]
            }
            try await dataSync.updateUser(user)
        }

        try await dataSync.commit()
        return actionId
    }
    
    //MARK: - Move action
    // if parentId is nil, move to backlog
    
    func moveAction(
        _ actionId: String,
        _ parentId: String? = nil,
        _ rank: Int = 0) async throws
    {
        
    }
    
    //MARK: - Complete action
    
    func completeAction(_ actionId: String) async throws
    {

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
