//
//  QueryBuilder.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/30/22.
//

import Foundation
import Firebase

class QueryBuilder<T: Storable> {
    var query: Query
    
    init(_ model: T.Type, rootPath: String? = nil) {
        var path = model.collection()
        if let rootPath = rootPath {
            path = rootPath + path
        }
        query = Firestore.firestore().collection(path)
    }
    
    @discardableResult
    func user(_ userId: String) -> Self {
        query = query.whereField("userId", isEqualTo: userId)
        return self
    }
    
    @discardableResult
    func whereField(_ field: String, isEqualTo value: Bool) -> Self {
        query = query.whereField(field, isEqualTo: value)
        return self
    }
    
    func build() -> Query {
        return query
    }
}
