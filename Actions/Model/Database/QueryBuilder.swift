//
//  QueryBuilder.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/30/22.
//

import Foundation
import Firebase

//MARK: - Query Builder

class QueryBuilder<T: Storable> {
    var predicates = [NSPredicate]()
    var rootPath = ""
    var collection: String
    
    init(_ model: T.Type) {
        collection = model.collection()
    }
    
    @discardableResult
    func rootPath(_ rootPath: String) -> Self {
        self.rootPath = rootPath
        return self
    }
    
    @discardableResult
    func whereField(_ field: String, isEqualTo value: Bool) -> Self {
        let predicate = NSPredicate(format: "\(field) == %d", value ? "YES" : "NO")
        predicates.append(predicate)
        return self
    }
    
    @discardableResult
    func whereField(_ field: String, isEqualTo value: String) -> Self {
        let predicate = NSPredicate(format: "\(field) == %@", value)
        predicates.append(predicate)
        return self
    }
    
    @discardableResult
    func whereField(_ field: String, notEqualTo value: String) -> Self {
        let predicate = NSPredicate(format: "\(field) != %@", value)
        predicates.append(predicate)
        return self
    }
    
    func build() -> Query {
        var query: Query = Firestore.firestore().collection(rootPath + collection)
        for predicate in predicates {
            query = query.filter(using: predicate)
        }
        return query
    }
}
