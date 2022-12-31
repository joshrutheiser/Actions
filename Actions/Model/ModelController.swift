//
//  ModelController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/31/22.
//

import Foundation

class ModelController {
    var databaseReader: DatabaseReader
    var databaseWriter: DatabaseWriter
    let session: String
    
    init(_ session: String, _ reader: DatabaseReader, _ writer: DatabaseWriter) {
        self.session = session
        databaseReader = reader
        databaseWriter = writer
        print("SESSION: \(session)")
    }
    
    private(set) var user: User? {
        didSet { print("USER UPDATED: \(user)") }
    }
    
    func setupUser(_ userId: String) {
        let query = QueryBuilder(User.self)
            .user(userId)
            .whereField("lastSession", notEqualTo: session)
        
        databaseReader.getDocuments(query, as: User.self) { [self] results in
            if let user = unwrapSingleResult(results) {
                self.user = user
            } else {
                var user = User(userId, session)
                let id = try? databaseWriter.create(as: User.self, user)
                user.id = id
                self.user = user
                databaseWriter.execute()
            }
            setupUserListener(query)
        }

    }
    
    func setupUserListener(_ query: QueryBuilder<User>) {
        databaseReader.listenDocuments(query, as: User.self) { [self] results in
            guard let user = unwrapSingleResult(results) else { return }
            self.user = user
        }
    }
        
    private func unwrapSingleResult<T: Storable>(
        _ results: [DatabaseReader.Difference<T>])
        -> T?
    {
        guard results.count == 1 else { return nil }
        return results.first?.object
    }
}
