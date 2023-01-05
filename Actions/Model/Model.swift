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
    var userId: String?
    var lastSession: String?
    var createdDate = Date()
    var lastUpdatedDate = Date()
    static func collection() -> String { "actions" }
    
    var text: String
    var parentId: String?
    var childIds = [String]()
    var scheduledDate: Date?
    var skipped = 0
    var isCompleted = false
    var isDeleted = false
    var completedDate: Date?
    var deletedDate: Date?
    
    init(_ text: String,
         _ parentId: String? = nil,
         userId: String? = nil,
         session: String? = nil)
    {
        self.text = text
        self.parentId = parentId
        self.userId = userId
        lastSession = session
    }
}

//MARK: - User
typealias Mode = User.Mode

struct User: Storable, Codable {
    @DocumentID var id: String?
    var userId: String?
    var lastSession: String?
    var createdDate = Date()
    var lastUpdatedDate = Date()
    static func collection() -> String { "users" }
    
    var currentMode: String
    var backlog: [String: [String]]
    
    init(userId: String? = nil,
         session: String? = nil)
    {
        self.userId = userId
        lastSession = session
        
        currentMode = Mode.Personal.rawValue
        backlog = [
            Mode.Personal.rawValue: [String](),
            Mode.Work.rawValue: [String]()
        ]
    }
    
    enum Mode: String, Codable {
        case Personal = "Personal"
        case Work = "Work"
    }

}

//MARK: - Storable

protocol Storable: Codable {
    var id: String? { get set }
    var userId: String? { get set }
    var lastSession: String? { get set }
    var createdDate: Date { get set }
    var lastUpdatedDate: Date { get set }
    static func collection() -> String
}

//MARK: - Constants

struct K {
    struct Title {
        static let today = "Today"
        static let backlog = "Backlog"
    }
}
