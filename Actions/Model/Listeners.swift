//
//  Listener.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class Listeners {
    private var firestore: Firestore
    private var actionsListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    init() {
        firestore = Firestore.firestore()
    }
    
    // returns dictionary of action ids and objects
    func startActions(_ handler: @escaping ([String: Action]?) -> Void) {
        
        actionsListener = firestore.collection(Collection.Actions.rawValue)
            .addSnapshotListener { snapshot, error in
                
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    handler(nil)
                    return
                }
                
                var results: [String: Action] = [:]
                for doc in documents {
                    do {
                        let action = try doc.data(as: Action.self)
                        guard let id = action.id else { continue }
                        results[id] = action
                    } catch {
                        print("Error decoding document: \(error.localizedDescription)")
                        continue
                    }
                }
                
                handler(results)
            }
    }
    
    func stopActions() {
        actionsListener?.remove()
    }
}
