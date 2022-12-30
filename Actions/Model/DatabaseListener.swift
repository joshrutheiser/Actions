//
//  DatabaseListener.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/30/22.
//

/*
 
    To do:
        - take out error handling responsibility from database class while standardizing errors
        - write firebase security rules for userId
        
 */

import Firebase
import FirebaseFirestoreSwift

//MARK: - Database Listen

class DatabaseListener {
    private var firestore: Firestore
    private var listeners: [ListenerRegistration]
    
    init() {
        firestore = Firestore.firestore()
        listeners = [ListenerRegistration]()
    }
    
    deinit {
        listeners.forEach({ $0.remove() })
    }
    
    //MARK: - Listen document
    
    func listenDocument<T: Storable>(_ id: String, as model: T.Type, handler: @escaping (T?) -> Void) {
        let docRef = firestore.collection(model.collection()).document(id)
        let listener = docRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error listening: ", error ?? "")
                handler(nil)
                return
            }
            
            do {
                let object = try snapshot.data(as: model)
                handler(object)
            } catch {
                print("Error decoding: ", error)
                handler(nil)
            }
        }
        listeners.append(listener)
    }
    
    //MARK: - Listen collection
    
    func listenCollection<T: Storable>(as model: T.Type, _ query: Query, handler: @escaping ([Difference<T>]?) -> Void) {
        let listener = query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error listening: ", error ?? "")
                handler(nil)
                return
            }
            
            var changes = [Difference<T>]()
            for diff in snapshot.documentChanges {
                do {
                    let object = try diff.document.data(as: model)
                    // not checking diff type since actions aren't physically deleted
                    switch diff.type {
                        case .added, .modified:
                            changes.append(Difference(.Updated, object))
                        case .removed:
                            changes.append(Difference(.Removed, object))
                    }
                } catch {
                    print("Error decoding: ", error)
                    handler(nil)
                    return
                }
            }
            handler(changes)
        }
        listeners.append(listener)
    }
    
    //MARK: - Difference

    struct Difference<T: Storable> {
        var change: Change
        var object: T
        
        init(_ change: Change, _ object: T) {
            self.change = change
            self.object = object
        }
        
        enum Change {
            case Updated
            case Removed
        }
    }
}
