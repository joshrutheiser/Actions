//
//  DatabaseReader.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/30/22.
//

import Firebase
import FirebaseFirestoreSwift

//MARK: - Database Listen

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
        as model: T.Type,
        handler: @escaping ([Difference<T>]) -> Void
    ){
        query.rootPath(rootPath)
        query.build().getDocuments {
            [self] (snapshot, error) in
            unpackSnapshot(from: (snapshot, error), as: model, to: handler)
        }
    }
    
    //MARK: - Listen documents
    
    func listenDocuments<T: Storable>(
        _ query: QueryBuilder<T>,
        as model: T.Type,
        handler: @escaping ([Difference<T>]) -> Void
    ){
        query.rootPath(rootPath)
        let listener = query.build().addSnapshotListener {
            [self] (snapshot, error) in
            unpackSnapshot(from: (snapshot, error), as: model, to: handler)
        }
        listeners.append(listener)
    }
    
    //MARK: - Unpack snapshot
    
    private func unpackSnapshot<T: Storable>(
        from result: (snapshot: QuerySnapshot?, error: Error?),
        as model: T.Type,
        to handler: @escaping ([Difference<T>]) -> Void
    ){
        guard let snapshot = result.snapshot else {
            print(Errors.UnknownListenError(result.error))
            handler([])
            return
        }
        
        var changes = [Difference<T>]()
        for diff in snapshot.documentChanges {
            do {
                let object = try diff.document.data(as: model)
                switch diff.type {
                    case .added, .modified:
                        changes.append(Difference(.Update, object))
                    case .removed:
                        changes.append(Difference(.Remove, object))
                }
            } catch {
                print(Errors.DecodeModelError(diff.document.documentID, error))
                continue
            }
        }
        handler(changes)
    }
    
    //MARK: - Difference

    struct Difference<T: Storable> {
        let change: Change
        let object: T
        
        init(_ change: Change, _ object: T) {
            self.change = change
            self.object = object
        }
        
        enum Change {
            case Update
            case Remove
        }
    }
    
    //MARK: - Errors
    
    enum Errors: Error {
        case DecodeModelError(_ id: String, _ error: Error)
        case UnknownListenError(_ error: Error?)
    }
}
