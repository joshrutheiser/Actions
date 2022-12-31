//
//  Test.swift
//  ActionsTests
//
//  Created by Josh Rutheiser on 12/30/22.
//

import Foundation
import FirebaseFirestoreSwift
@testable import Actions

struct Test: Storable, Codable {
    @DocumentID var id: String?
    var userId: String
    var lastSession: String
    static func collection() -> String { "tests" }
    
    var createdDate = Date()
    var description: String
    
    init(_ userId: String, _ description: String, _ session: String) {
        self.userId = userId
        self.description = description
        lastSession = session
    }
}
