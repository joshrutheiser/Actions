//
//  Database.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum Collection: String {
    case Actions = "actions"
}

class Operations {
    private var firestore: Firestore
    private var writeBatch: WriteBatch
    
    init() {
        firestore = Firestore.firestore()
        writeBatch = firestore.batch()
    }
    
    func createAction(_ text: String) -> String? {
        do {
            let docRef = firestore.collection(Collection.Actions.rawValue).document()
            try writeBatch.setData(from: Action(text: text), forDocument: docRef)
            return docRef.documentID
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func execute() {
        writeBatch.commit { error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            self.writeBatch = self.firestore.batch()
        }
    }
}
