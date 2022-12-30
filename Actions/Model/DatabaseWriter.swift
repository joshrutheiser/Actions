//
//  DatabaseWriter.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

/*
 
    To do:
        - take out error handling responsibility from database class while standardizing errors
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

    //MARK: - create
    
    func create<T: Storable>(as model: T.Type, _ object: T) -> String? {
        do {
            let docRef = firestore.collection(model.collection()).document()
            try writeBatch.setData(from: object, forDocument: docRef)
            return docRef.documentID
        } catch {
            print("Error creating object: ", error)
            return nil
        }
    }
    
    //MARK: - update
    
    func update<T: Storable>(as model: T.Type, _ object: T) {
        do {
            guard let id = object.id else { print("Update missing id"); return }
            let docRef = firestore.collection(model.collection()).document(id)
            try writeBatch.setData(from: object, forDocument: docRef)
        } catch {
            print("Error updating object: ", error)
        }
    }
    
    //MARK: - execute
    
    func execute() {
        writeBatch.commit { error in
            if let error = error {
                print("Error committing write batch: ", error)
            }
            
            self.writeBatch = self.firestore.batch()
        }
    }
}
