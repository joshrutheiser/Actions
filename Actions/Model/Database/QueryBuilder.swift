//
//  QueryBuilder.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/30/22.
//

import Foundation
import Firebase

enum Predicate {
    case isEqualToBool(_ field: String, _ value: Bool)
    case isEqualToString(_ field: String, _ value: String)
    case isNotEqualToString(_ field: String, _ value: String)
    case isGreaterThanDate(_ field: String, _ value: Date)
}

//MARK: - Query Builder

class QueryBuilder<T: Storable> {
    var predicates = [Predicate]()
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
        predicates.append(.isEqualToBool(field, value))
        return self
    }
    
    @discardableResult
    func whereField(_ field: String, isEqualTo value: String) -> Self {
        predicates.append(.isEqualToString(field, value))
        return self
    }
    
    @discardableResult
    func whereField(_ field: String, notEqualTo value: String) -> Self {
        predicates.append(.isNotEqualToString(field, value))
        return self
    }
    
    @discardableResult
    func whereField(_ field: String, isGreaterThan value: Date) -> Self {
        predicates.append(.isGreaterThanDate(field, value))
        return self
    }
    
    //MARK: - Build
    
    func build() -> Query {
        var query: Query = Firestore.firestore().collection(rootPath + collection)
        for predicate in predicates {
            switch predicate {
            case .isNotEqualToString(let field, let value):
                query = query.whereField(field, isNotEqualTo: value)
            case .isEqualToString(let field, let value):
                query = query.whereField(field, isEqualTo: value)
            case .isEqualToBool(let field, let value):
                query = query.whereField(field, isEqualTo: value)
            case .isGreaterThanDate(let field, let value):
                query = query.whereField(field, isGreaterThan: value)
            }
        }
        
        return query
    }
}
