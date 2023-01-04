//
//  DatabaseReader.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/30/22.
//

import Firebase
import FirebaseFirestoreSwift

//MARK: - Database Reader

class DatabaseReader {
    private var firestore: Firestore
    private var listeners: [ListenerRegistration]
    private var rootPath: String
    
    init() {
        firestore = Firestore.firestore()
        listeners = [ListenerRegistration]()
        rootPath = ""
    }
    
    func setRootPath(_ rootPath: String) {
        self.rootPath = rootPath
    }
    
    deinit {
        listeners.forEach({ $0.remove() })
    }
    
    //MARK: - Get documents
    
    func getDocuments<T: Storable>(
        _ query: QueryBuilder<T>,
        as model: T.Type) async throws -> [Difference<T>]
    {
        query.rootPath(rootPath)
        let snapshot = try await query.build().getDocuments()
        return unpackSnapshot(from: (snapshot, nil), as: model)
    }
    
    //MARK: - Listen documents
    
    func listenDocuments<T: Storable>(
        _ query: QueryBuilder<T>,
        as model: T.Type,
        handler: @escaping ([Difference<T>]) -> Void)
    {
        query.rootPath(rootPath)
        let listener = query.build().addSnapshotListener { snapshot, error in
            let result = self.unpackSnapshot(from: (snapshot, error), as: model)
            handler(result)
        }
        listeners.append(listener)
    }
    
    //MARK: - Unpack snapshot
    // errors convert to empty results, so one bad formatted object doesn't
    // lead to no data returned to the user
    
    private func unpackSnapshot<T: Storable>(
        from input: (snapshot: QuerySnapshot?, error: Error?),
        as model: T.Type) -> [Difference<T>]
    {
        if let error = input.error { print(error); return [] }
        guard let changes = input.snapshot?.documentChanges else { return [] }

        let results: [Difference<T>] = changes.compactMap { diff in
            let result = Result { try diff.document.data(as: model) }
            switch result {
            case let .failure(error):
                print(error)
                return nil
            case let .success(object):
                return Difference(diff.type, object)
            }
        }

        return results
    }
}

//MARK: - Difference

struct Difference<T: Storable> {
    enum Change {
        case Set, Remove
    }
    
    let change: Change
    let object: T
    
    init(_ change: Change, _ object: T) {
        self.change = change
        self.object = object
    }
    
    init(_ change: DocumentChangeType, _ object: T) {
        switch change {
        case .added, .modified:
            self.init(.Set, object)
        case .removed:
            self.init(.Remove, object)
        }
    }
}
