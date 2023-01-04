//
//  DataSync+Get.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/2/23.
//

import Foundation

//MARK: - Get

extension ModelController {
    
    //MARK: - Action
    
    func getText(_ actionId: String) async throws -> String {
        return try await getAction(actionId).text
    }
    
    func getAction(_ actionId: String) async throws -> Action {
        guard let action = await dataSync.getAction(actionId) else {
            throw Errors.ActionMissing(actionId)
        }
        return action
    }
    
    func getChildActionId(
        _ parentId: String,
        _ rank: Int) async throws -> String?
    {
        guard let children = try await getChildActionIds(parentId) else {
            return nil
        }
        guard rank < children.count else {
            throw Errors.RankOutOfBounds(parentId, children.count, rank)
        }
        return children[rank]
    }
    
    func getChildActionIds(_ parentId: String) async throws -> [String]? {
        return try await getAction(parentId).childIds
    }
    
    func getSchedule(_ actionId: String) async throws -> Date? {
        return try await getAction(actionId).scheduledDate
    }
    
    //MARK: - User
    
    func getUser() async throws -> User {
        guard let user = await dataSync.getUser() else {
            throw Errors.UserNotLoaded
        }
        return user
    }
    
    func getBacklog() async throws -> [String]? {
        let user = try await getUser()
        let mode = try await getMode()
        return user.backlog[mode]
    }
    
    func getToday() async throws -> [String]? {
        let user = try await getUser()
        let mode = try await getMode()
        return user.today[mode]
    }
    
    func getMode() async throws -> String {
        let user = try await getUser()
        return user.currentMode
    }
    
}
