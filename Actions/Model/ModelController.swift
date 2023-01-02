//
//  ModelController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/31/22.
//

import Foundation

class ModelController {
    lazy var cache = MemoryCache(delegate: self)
    var databaseReader: DatabaseReader
    var databaseWriter: DatabaseWriter
    let session: String
    
    init(_ session: String, _ reader: DatabaseReader, _ writer: DatabaseWriter) {
        self.session = session
        databaseReader = reader
        databaseWriter = writer
    }
}

//MARK: - Read

extension ModelController {
    
    //MARK: - Setup user
    
    func setupUser(_ userId: String) async throws {
        let query = QueryBuilder(User.self)
            .user(userId)
            .whereField("lastSession", notEqualTo: session)

        let results = try await databaseReader.getDocuments(query, as: User.self)
        if let user = results.first?.object {
            await cache.updateUser(user)
        } else {
            var user = User(userId, session)
            let id = try databaseWriter.create(as: User.self, user)
            user.id = id
            await cache.updateUser(user)
            try await databaseWriter.execute()
        }
        
        setupUserListener(query)
    }
        
    private func setupUserListener(_ query: QueryBuilder<User>) {
        databaseReader.listenDocuments(query, as: User.self) { results in
            guard let user = results.first?.object else { return }
            Task {
                await self.cache.updateUser(user)
            }
        }
    }

    //MARK: - Setup actions
    
    func setupActions(_ userId: String) async {
        let query = QueryBuilder(Action.self)
            .user(userId)
            .whereField("lastSession", notEqualTo: session)
            .whereField("isCompleted", isEqualTo: false)
            .whereField("isDeleted", isEqualTo: false)
        
        databaseReader.listenDocuments(query, as: Action.self) { results in
            Task {
                await self.cache.updateActions(results)
            }
        }
    }
}

//MARK: - Write

extension ModelController {
    
    //MARK: - Create action
    // if parentId is nil, add to backlog

    func createAction(
        _ text: String,
        _ parentId: String? = nil,
        _ rank: Int = 0) async throws -> String
    {
                
        return ""
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
    
    func completeAction(
        _ actionId: String) async throws
    {
        
    }
    
    //MARK: - Delete action
    
    func deleteAction(
        _ actionId: String) async throws
    {
        
    }
    
    //MARK: - Clear today
    
    
    
    //MARK: - Add today
    
    
    
    //MARK: - Remove today
}

//MARK: - Cache delegate

extension ModelController: MemoryCacheDelegate {
    
    func userUpdated(_ user: User) {
        print("USER UPDATED! \(user)")
    }
    
    func actionsUpdated(_ actions: [String : Action]) {
        print("ACTIONS UPDATED! \(actions)")
    }
    
}
