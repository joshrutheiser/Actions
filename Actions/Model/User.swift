//
//  User.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var id: String?
    var userId: String
    var backlog: [String]
}