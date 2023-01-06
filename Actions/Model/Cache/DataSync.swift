//
//  DataSync.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/2/23.
//

import Foundation

//MARK: - Config

struct DataSyncConfig {
    let databaseWriter: DatabaseWriter
    let databaseReader: DatabaseReader
    let cache: LocalCache
    let session: String
    let userId: String
}

//MARK: - Data Sync

struct DataSync {
    private let config: DataSyncConfig

    init(_ config: DataSyncConfig) {
        self.config = config
    }
    
    //MARK: - Listen
    
    func listen() async throws {
        try await listenUser()
        await listenActions()
    }
    
    // listens to database changes
        
    private func listenUser() async throws {
        let query = QueryBuilder(User.self)
            .whereField("userId", isEqualTo: config.userId)
//            .whereField("lastSession", notEqualTo: config.session)

        let results = try await config.databaseReader.getDocuments(query, as: User.self)
        if let user = results.first?.object {
            await config.cache.setUser(user)
        } else {
            try await createUser()
        }
        try await commit()
        
        config.databaseReader.listenDocuments(query, as: User.self) {
            results in
            guard let user = results.first?.object else { return }
            #warning ("TODO: remove print")
            print("listen user called")
            Task {
                #warning ("TODO: decide if this is the right session approach")
                if user.lastSession != config.session {
                    await self.config.cache.setUser(user)
                }
            }
        }
    }
    
    private func listenActions() async {
        #warning ("TODO: test that this query works")
        let query = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: config.userId)
            .whereField("isCompleted", isEqualTo: false)
            .whereField("isDeleted", isEqualTo: false)
            .whereField("lastSession", notEqualTo: config.session)
        
        config.databaseReader.listenDocuments(query, as: Action.self) {
            results in
            #warning ("TODO: remove print")
            print("listen actions called")
            Task {
                await self.config.cache.setActions(results)
            }
        }
    }
    
    //MARK: - Get action
    
    func getAction(_ actionId: String) async -> Action? {
        return await config.cache.actions?[actionId]
    }
    
    //MARK: - Get user
    
    func getUser() async -> User? {
        return await config.cache.user
    }
    
    //MARK: - Create action
    
    func createAction(_ action: Action) async throws -> String {
        #warning ("TODO: remove print")
        print("create action called")
        var updated = action
        updated.lastSession = config.session
        updated.userId = config.userId
        let id = try config.databaseWriter.create(as: Action.self, updated)
        updated.id = id
        await config.cache.setAction(updated)
        return id
    }
    
    //MARK: - Update action
    
    func updateAction(_ action: Action) async throws {
        #warning ("TODO: remove print")
        print("update action called")
        var updated = action
        updated.lastUpdatedDate = Date()
        updated.lastSession = config.session
        try config.databaseWriter.update(as: Action.self, updated)
        await config.cache.setAction(updated)
    }
    
    //MARK: - Create user
    
    func createUser() async throws {
        #warning ("TODO: remove print")
        print("create user called")
        var user = User(userId: config.userId, session: config.session)
        let id = try config.databaseWriter.create(as: User.self, user)
        user.id = id
        await config.cache.setUser(user)
    }
    
    //MARK: - Update user
    
    func updateUser(_ user: User) async throws {
        #warning ("TODO: remove print")
        print("user updated called")
        var updated = user
        updated.lastUpdatedDate = Date()
        updated.lastSession = config.session
        try config.databaseWriter.update(as: User.self, updated)
        await config.cache.setUser(updated)
    }
    
    //MARK: - Commit
    
    func commit() async throws {
        try await config.databaseWriter.commit()
    }
}
