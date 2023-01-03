//
//  ModelController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/31/22.
//

import Foundation

class ModelController {
    lazy var syncWriter = SyncWriter(databaseWriter, data, session)
    lazy var data = LocalCache(self)
    var databaseReader: DatabaseReader
    var databaseWriter: DatabaseWriter
    let session: String
    
    init(_ session: String,
         _ reader: DatabaseReader,
         _ writer: DatabaseWriter)
    {
        self.session = session
        databaseReader = reader
        databaseWriter = writer
    }
}

//MARK: - Setup

extension ModelController {
    
    func setup(_ userId: String) async throws {
        try await setupUser(userId)
        await setupActions(userId)
    }
    
    //MARK: - Setup user
    
    private func setupUser(_ userId: String) async throws {
        let query = QueryBuilder(User.self)
            .user(userId)
            .whereField("lastSession", notEqualTo: session)

        let results = try await databaseReader.getDocuments(query, as: User.self)
        if let user = results.first?.object {
            await data.setUserNotify(user)
        } else {
            let user = User(userId, session)
            try await syncWriter.createUser(user)
        }
        try await syncWriter.commit()
        
        setupUserListener(query)
    }
        
    private func setupUserListener(_ query: QueryBuilder<User>) {
        databaseReader.listenDocuments(query, as: User.self) { results in
            guard let user = results.first?.object else { return }
            Task {
                await self.data.setUserNotify(user)
            }
        }
    }

    //MARK: - Setup actions
    
    private func setupActions(_ userId: String) async {
        let query = QueryBuilder(Action.self)
            .user(userId)
            .whereField("lastSession", notEqualTo: session)
            .whereField("isCompleted", isEqualTo: false)
            .whereField("isDeleted", isEqualTo: false)
        
        databaseReader.listenDocuments(query, as: Action.self) { results in
            Task {
                await self.data.setActionsNotify(results)
            }
        }
    }
}

//MARK: - Write

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
        let action = Action(user.userId, text, session, parentId)
        let actionId = try await syncWriter.createAction(action)
        
        if let parentId = parentId {
            // add to parent action
            var parent = try await getAction(parentId)
            try checkArrayBounds(parentId, parent.childIds, rank)
            parent.childIds.insert(actionId, at: rank)
            try await syncWriter.updateAction(parent)
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
            try await syncWriter.updateUser(user)
        }

        try await syncWriter.commit()
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

//MARK: - Cache delegate

extension ModelController: LocalCacheDelegate {
    
    func userUpdated(_ user: User) {
        print("USER UPDATED! \(user)")
    }
    
    func actionsUpdated(_ actions: [String : Action]) {
        print("ACTIONS UPDATED! \(actions)")
    }
    
}

//MARK: - Error

extension ModelController {
    enum Errors: Error {
        case UserNotLoaded
        case RankOutOfBounds(_ parentId: String, _ count: Int, _ rank: Int)
        case ActionMissing(_ id: String)
    }
}
