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
    var cache: LocalCache
    let session: String
    let userId: String
}

//MARK: - Data Sync

class DataSync {
    private var config: DataSyncConfig

    init(_ config: DataSyncConfig) {
        self.config = config
    }
       
    // initial load and then listens to database changes

    func startListening() async throws {
        try await listenUser()
        try await listenActions()
    }
    
    //MARK: - Listen User
        
    private func listenUser() async throws {
        let query = QueryBuilder(User.self)
            .whereField("userId", isEqualTo: config.userId)
            .whereField("lastSession", notEqualTo: config.session)

        // create user if doesn't exist
        let results = try await config.databaseReader.getDocuments(query, as: User.self)
        if results.first?.object == nil {
            try createUser()
            try await commit()
        }
        
        config.databaseReader.listenDocuments(query, as: User.self) {
            results in
            guard let user = results.first?.object else { return }
            self.config.cache.setUser(user)
            self.config.cache.notify()
        }
    }
    
    //MARK: - Listen Actions
    
    private func listenActions() async throws {

        // initial load of actions
        let loadQuery = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: config.userId)
            .whereField("isCompleted", isEqualTo: false)
            .whereField("isDeleted", isEqualTo: false)
        
        let results = try await config.databaseReader.getDocuments(loadQuery, as: Action.self)
        config.cache.setActions(results)
        config.cache.notify()
        
        // set up listener for only new changes
        let listenQuery = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: config.userId)
            .whereField("lastUpdatedDate", isGreaterThan: Date())

        config.databaseReader.listenDocuments(listenQuery, as: Action.self) {
            results in
            // only publish changes from other sessions because current
            // session changes are published to cache directly
            let filtered = results.filter { $0.object.lastSession != self.config.session }
            guard filtered.isEmpty == false else { return }
            
            self.config.cache.setActions(filtered)
            self.config.cache.notify()
        }
    }
    
    //MARK: - Get action
    
    func getAction(_ actionId: String) -> Action? {
        return config.cache.actions?[actionId]
    }
    
    func getActions() -> [String: Action]? {
        return config.cache.actions
    }
    
    //MARK: - Get user
    
    func getUser() -> User? {
        return config.cache.user
    }
    
    //MARK: - Create action
    
    func createAction(_ action: Action) throws -> String {
        var updated = action
        updated.lastSession = config.session
        updated.userId = config.userId
        let id = try config.databaseWriter.create(as: Action.self, updated)
        updated.id = id
        config.cache.setAction(updated)
        return id
    }
    
    //MARK: - Update action
    
    func updateAction(_ action: Action) throws {
        var updated = action
        updated.lastUpdatedDate = Date()
        updated.lastSession = config.session
        try config.databaseWriter.update(as: Action.self, updated)
        config.cache.setAction(updated)
    }
    
    //MARK: - Create user
    
    func createUser() throws {
        var user = User(userId: config.userId, session: config.session)
        let id = try config.databaseWriter.create(as: User.self, user)
        user.id = id
        config.cache.setUser(user)
    }
    
    //MARK: - Update user
    
    func updateUser(_ user: User) throws {
        var updated = user
        updated.lastUpdatedDate = Date()
        updated.lastSession = config.session
        try config.databaseWriter.update(as: User.self, updated)
        config.cache.setUser(updated)
    }
    
    //MARK: - Commit
    
    func commit() async throws {
        config.cache.notify()
        try await config.databaseWriter.commit()
    }
}
