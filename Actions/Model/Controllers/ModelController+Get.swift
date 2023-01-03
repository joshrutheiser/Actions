//
//  ModelController+Get.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/2/23.
//

import Foundation

//MARK: - Get

extension ModelController {
    
    //MARK: - Action
    
    func getText(_ actionId: String) async -> String? {
        return await data.actions?[actionId]?.text
    }
    
    func getAction(_ actionId: String) async throws -> Action {
        guard let action = await data.actions?[actionId] else {
            throw Errors.ActionMissing(actionId)
        }
        return action
    }
    
    func getChildActionId(
        _ parentId: String,
        _ rank: Int) async -> String?
    {
        guard let children = await getChildActionIds(parentId) else { return nil }
        guard rank < children.count else { return nil }
        return children[rank]
    }
    
    func getChildActionIds(_ parentId: String) async -> [String]? {
        return await data.actions?[parentId]?.childIds
    }
    
    func getSchedule(_ actionId: String) async -> Date? {
        return await data.actions?[actionId]?.scheduledDate
    }
    
    //MARK: - User
    
    func getUser() async throws -> User {
        guard let user = await data.user else { throw Errors.UserNotLoaded }
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
