//
//  DataSync.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/2/23.
//

import Foundation

//MARK: - Config

struct DataSyncConfig {
    let session: String
    let userId: String
    var rootPath = ""
}

//MARK: - Data Sync

class DataSync {
    private let config: DataSyncConfig
    private let reader: DatabaseReader
    private let writer: DatabaseWriter
    private var cache: LocalCache
    
    init(_ config: DataSyncConfig) {
        self.config = config
        reader = DatabaseReader(config.rootPath)
        writer = DatabaseWriter(config.rootPath)
        cache = LocalCache()
    }
    
    //MARK: - Observers
    
    func addObserver(_ observer: LocalCacheObserver) {
        cache.observers.append(observer)
    }
    
    func removeObserver(_ observer: LocalCacheObserver) {
        cache.observers.removeAll(where: { $0 === observer })
    }
       
    // initial load and then listens to database changes

    func startListening() async throws {
        try await listenUser()
        try await listenActions()
    }
    
    //MARK: - Listen User
        
    private func listenUser() async throws {
        // check for session not equal to current was removed from query
        // because of bad behavior where user loaded from previous session
        // was then removed when updated, resulting in the old user object
        // being sent to the listener along with a remove command
        let query = QueryBuilder(User.self)
            .whereField("userId", isEqualTo: config.userId)

        // create user if doesn't exist
        let results = try await reader.getDocuments(query, as: User.self)
        if results.first?.object == nil {
            try createUser()
            try commit()
        }
        
        reader.listenDocuments(query, as: User.self) {
            results in
            guard let result = results.first else { return }
            // only publish changes from other sessions because current
            // session changes are published to cache directly
            guard result.object.lastSession != self.config.session else { return }
            self.cache.setUser(result.object)
            self.cache.notify(source: .External)
        }
    }
    
    //MARK: - Listen Actions
    
    private func listenActions() async throws {

        // initial load of actions
        let loadQuery = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: config.userId)
            .whereField("isCompleted", isEqualTo: false)
            .whereField("isDeleted", isEqualTo: false)
        
        let results = try await reader.getDocuments(loadQuery, as: Action.self)
        cache.setActions(results)
        cache.notify(source: .External)
        
        // set up listener for only new changes
        let listenQuery = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: config.userId)
            .whereField("lastUpdatedDate", isGreaterThan: Date())

        reader.listenDocuments(listenQuery, as: Action.self) {
            results in
            // only publish changes from other sessions because current
            // session changes are published to cache directly
            let filtered = results.filter { $0.object.lastSession != self.config.session }
            guard filtered.isEmpty == false else { return }
            
            self.cache.setActions(filtered)
            self.cache.notify(source: .External)
        }
    }
    
    //MARK: - Get action
    
    func getAction(_ actionId: String) -> Action? {
        return cache.actions?[actionId]
    }
    
    func getActions() -> [String: Action]? {
        return cache.actions
    }
    
    //MARK: - Get user
    
    func getUser() -> User? {
        return cache.user
    }
    
    //MARK: - Create action
    
    func createAction(_ action: Action) throws -> String {
        var updated = action
        updated.lastSession = config.session
        updated.userId = config.userId
        let id = try writer.create(as: Action.self, updated)
        updated.id = id
        cache.setAction(updated)
        return id
    }
    
    //MARK: - Update action
    
    func updateAction(_ action: Action) throws {
        var updated = action
        updated.lastUpdatedDate = Date()
        updated.lastSession = config.session
        try writer.update(as: Action.self, updated)
        cache.setAction(updated)
    }
    
    //MARK: - Create user
    
    func createUser() throws {
        var user = User(userId: config.userId, session: config.session)
        let id = try writer.create(as: User.self, user)
        user.id = id
        cache.setUser(user)
    }
    
    //MARK: - Update user
    
    func updateUser(_ user: User) throws {
        var updated = user
        updated.lastUpdatedDate = Date()
        updated.lastSession = config.session
        try writer.update(as: User.self, updated)
        cache.setUser(updated)
    }
    
    //MARK: - Commit
    
    func commit(notify: Bool = true) throws {
        if notify {
            cache.notify(source: .Internal)
        }
        try writer.commit()
    }
}
