//
//  DatabaseWriter.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

/*
 
    To do:
        - write firebase security rules for userId
        
 */

import Foundation
import Firebase
import FirebaseFirestoreSwift

//MARK: - Database Write

class DatabaseWriter {
    private var firestore: Firestore
    private var writeBatch: WriteBatch
    
    init() {
        firestore = Firestore.firestore()
        writeBatch = firestore.batch()
    }
    
    func reset() {
        writeBatch = firestore.batch()
    }

    //MARK: - create
    
    func create<T: Storable>(as model: T.Type, _ object: T) throws -> String {
        do {
            let docRef = firestore.collection(model.collection()).document()
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
            let docRef = firestore.collection(model.collection()).document(id)
            try writeBatch.setData(from: object, forDocument: docRef)
        } catch {
            throw Errors.UnknownUpdateWriteError(error)
        }
    }
    
    //MARK: - execute
    
    func execute() {
        writeBatch.commit { error in
            if let error = error {
                print(Errors.BatchWriteError(error))
            }
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
