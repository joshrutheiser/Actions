//
//  ReadController.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/4/23.
//

import Foundation

//MARK: - Read Controller

class ReadController {
    private var dataSync: DataSync
    
    init(_ dataSync: DataSync) {
        self.dataSync = dataSync
    }
    
    //MARK: - Load
    
    func load() async throws {
        try await dataSync.listen()
    }
    
    //MARK: - Action get
    
    func getText(_ actionId: String) async throws -> String {
        return try await getAction(actionId).text
    }
    
    func getAction(_ actionId: String) async throws -> Action {
        guard let action = await dataSync.getAction(actionId) else {
            throw ModelError.ActionMissing(actionId)
        }
        return action
    }
    
    func getParentId(_ actionId: String) async throws -> String? {
        let action = try await getAction(actionId)
        return action.parentId
    }
    
    func getParent(_ actionId: String) async throws -> Action {
        let action = try await getAction(actionId)
        guard let parentId = action.parentId else {
            throw ModelError.ActionHasNoParent(actionId)
        }
        return try await getAction(parentId)
    }
    
    func getChildActionId(
        _ parentId: String,
        _ rank: Int) async throws -> String?
    {
        guard let children = try await getChildActionIds(parentId) else {
            return nil
        }
        guard rank < children.count else {
            throw ModelError.RankOutOfBounds(parentId, children.count, rank)
        }
        return children[rank]
    }
    
    func getChildActionIds(_ parentId: String) async throws -> [String]? {
        return try await getAction(parentId).childIds
    }
    
    func getSchedule(_ actionId: String) async throws -> Date? {
        return try await getAction(actionId).scheduledDate
    }
    
    //MARK: - User get
    
    func getUser() async throws -> User {
        guard let user = await dataSync.getUser() else {
            throw ModelError.UserNotLoaded
        }
        return user
    }
    
    func getMode() async throws -> String {
        let user = try await getUser()
        return user.currentMode
    }
    
    func getBacklog() async throws -> [String]? {
        let user = try await getUser()
        let mode = try await getMode()
        return user.backlog[mode]
    }
    
}
