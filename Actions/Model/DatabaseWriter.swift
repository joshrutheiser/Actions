//
//  DatabaseWriter.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

//MARK: - Database Write

class DatabaseWriter {
    private var firestore: Firestore
    private var writeBatch: WriteBatch
    private var rootPath: String
    
    init() {
        rootPath = ""
        firestore = Firestore.firestore()
        writeBatch = firestore.batch()
    }
    
    func reset() {
        writeBatch = firestore.batch()
    }
    
    func setRootPath(_ rootPath: String) {
        self.rootPath = rootPath
    }

    //MARK: - create
    
    func create<T: Storable>(as model: T.Type, _ object: T) throws -> String {
        do {
            let path = rootPath + model.collection()
            let docRef = firestore.collection(path).document()
            try writeBatch.setData(from: object, forDocument: docRef)
            return docRef.documentID
        } catch {
            throw Errors.ModelCreateError(object, error)
        }
    }
    
    //MARK: - update
    
    func update<T: Storable>(as model: T.Type, _ object: T) throws {
        do {
            guard let id = object.id else { throw Errors.ModelUpdateMissingId(object) }
            let path = rootPath + model.collection()
            let docRef = firestore.collection(path).document(id)
            try writeBatch.setData(from: object, forDocument: docRef)
        } catch {
            throw Errors.UnknownUpdateWriteError(error)
        }
    }
    
    //MARK: - execute
    
    func execute(_ handler: @escaping () -> Void = {}) {
        writeBatch.commit { error in
            if let error = error {
                print(Errors.BatchWriteError(error))
            }
            handler()
        }
        reset()
    }
    
    //MARK: - Errors
    
    enum Errors: Error {
        case BatchWriteError(_ error: Error)
        case ModelCreateError(_ model: Any, _ error: Error)
        case ModelUpdateMissingId(_ model: Any)
        case UnknownUpdateWriteError(_ error: Error)
    }
}
