//
//  Model.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation
import FirebaseFirestoreSwift

//MARK: - Action

struct Action: Storable, Codable {
    @DocumentID var id: String?
    var userId: String
    static func collection() -> String { "actions" }
    
    var text: String
}

//MARK: - User

struct User: Storable, Codable {
    @DocumentID var id: String?
    var userId: String
    static func collection() -> String { "users" }
}

//MARK: - Storable

protocol Storable: Codable {
    var id: String? { get set }
    var userId: String { get set }
    static func collection() -> String
}
