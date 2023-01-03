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
    private var cache: LocalCache?
    
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
        let path = rootPath + model.collection()
        let docRef = firestore.collection(path).document()
        try writeBatch.setData(from: object, forDocument: docRef)
        return docRef.documentID
    }
    
    //MARK: - update
    
    func update<T: Storable>(as model: T.Type, _ object: T) throws {
        guard let id = object.id else { throw Errors.ModelUpdateMissingId(object) }
        let path = rootPath + model.collection()
        let docRef = firestore.collection(path).document(id)
        try writeBatch.setData(from: object, forDocument: docRef)
    }
    
    //MARK: - execute
    
    func commit() async throws {
        try await writeBatch.commit()
        reset()
    }
    
    //MARK: - Errors
    
    enum Errors: Error {
        case ModelUpdateMissingId(_ model: Any)
    }
}
