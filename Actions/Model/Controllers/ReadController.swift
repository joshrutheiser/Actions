//
//  ReadController.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/4/23.
//

import Foundation

//MARK: - Read Controller

class ReadController {
    private let dataSync: DataSync
    
    init(_ dataSync: DataSync) {
        self.dataSync = dataSync
    }
    
    //MARK: - Load
    
    func startListening() async throws {
        try await dataSync.startListening()
    }
    
    //MARK: - Action get
    
    func getAction(_ actionId: String) throws -> Action {
        guard let action = dataSync.getAction(actionId) else {
            throw ModelError.ActionMissing(actionId)
        }
        return action
    }
    
    func getParentId(_ actionId: String) throws -> String? {
        let action = try getAction(actionId)
        return action.parentId
    }
    
    func getParent(_ actionId: String) throws -> Action {
        let action = try getAction(actionId)
        guard let parentId = action.parentId else {
            throw ModelError.ActionHasNoParent(actionId)
        }
        return try getAction(parentId)
    }
    
    func getChildActionId(
        _ parentId: String,
        _ rank: Int) throws -> String?
    {
        let children = try getChildActionIds(parentId)
        guard rank < children.count else {
            throw ModelError.RankOutOfBounds(parentId, children.count, rank)
        }
        return children[rank]
    }
    
    func getChildActionIds(_ parentId: String) throws -> [String] {
        return try getAction(parentId).childIds
    }
    
    func getSchedule(_ actionId: String) throws -> Date? {
        return try getAction(actionId).scheduledDate
    }
    
    //MARK: - User get
    
    func getUser() throws -> User {
        guard let user = dataSync.getUser() else {
            throw ModelError.UserNotLoaded
        }
        return user
    }
    
    func getMode() throws -> String {
        return try getUser().currentMode
    }
    
    func getBacklog() throws -> [String] {
        let user = try getUser()
        let mode = user.currentMode
        guard let backlog = user.backlog[mode] else {
            throw ModelError.BacklogNotFound(mode)
        }
        return backlog
    }
    
    //MARK: - Is set
    
    func isUserSet() -> Bool {
        return dataSync.getUser() != nil
    }
    
    func isActionsSet() -> Bool {
        return dataSync.getActions() != nil
    }
}
