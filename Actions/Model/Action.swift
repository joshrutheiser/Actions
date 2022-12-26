//
//  Action.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Action: Codable {
    @DocumentID var id: String?
    var text: String
}
