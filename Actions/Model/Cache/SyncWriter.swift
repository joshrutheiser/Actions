//
//  SyncWriter.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/2/23.
//

import Foundation

//MARK: - Sync Writer

struct SyncWriter {
    private let databaseWriter: DatabaseWriter
    private let cache: LocalCache
    private let session: String
    
    init(_ databaseWriter: DatabaseWriter,
         _ cache: LocalCache,
         _ session: String)
    {
        self.databaseWriter = databaseWriter
        self.cache = cache
        self.session = session
    }
    
    //MARK: - Create action
    
    func createAction(_ action: Action) async throws -> String {
        let actionId = try databaseWriter.create(as: Action.self, action)
        var updated = action
        updated.id = actionId
        await cache.setAction(updated)
        return actionId
    }
    
    //MARK: - Update action
    
    func updateAction(_ action: Action) async throws {
        var updated = action
        updated.lastUpdatedDate = Date()
        updated.lastSession = session
        try databaseWriter.update(as: Action.self, updated)
        await cache.setAction(updated)
    }
    
    //MARK: - Create user
    
    func createUser(_ user: User) async throws {
        let userId = try databaseWriter.create(as: User.self, user)
        var updated = user
        updated.id = userId
        await cache.setUserNotify(updated)
    }
    
    //MARK: - Update user
    
    func updateUser(_ user: User) async throws {
        var updated = user
        updated.lastUpdatedDate = Date()
        updated.lastSession = session
        try databaseWriter.update(as: User.self, updated)
        await cache.setUser(updated)
    }
    
    //MARK: - Commit
    
    func commit() async throws {
        try await databaseWriter.commit()
    }
}
