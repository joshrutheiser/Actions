//
//  DatabaseWriter.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

//MARK: - Database Writer

class DatabaseWriter {
    private var firestore: Firestore
    private var writeBatch: WriteBatch
    private var rootPath: String
    
    init(_ rootPath: String = "") {
        self.rootPath = rootPath
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
    
    func commit() throws {
        // temporarily save the write batch
        // and reset to free up batch writing for
        // the next change, otherwise leads to
        // write failures or data races
        let tempBatch = writeBatch
        reset()
        Task {
            
            #warning ("TODO: how to propagate errors from here to outside the Task")
            
            try await tempBatch.commit()
        }
    }
    
    //MARK: - Errors
    
    enum Errors: Error {
        case ModelUpdateMissingId(_ model: Any)
    }
}
