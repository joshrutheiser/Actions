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
    
    init(_ userId: String, _ text: String) {
        self.userId = userId
        self.text = text
    }
}

//MARK: - User

struct User: Storable, Codable {
    @DocumentID var id: String?
    var userId: String
    static func collection() -> String { "users" }
    
    var currentMode: Mode = .Personal

    init(_ userId: String) {
        self.userId = userId
    }
    
    enum Mode: String, Codable {
        case Personal = "Personal"
        case Work = "Work"
    }
}

//MARK: - Storable

protocol Storable: Codable {
    var id: String? { get set }
    var userId: String { get set }
    static func collection() -> String
}
