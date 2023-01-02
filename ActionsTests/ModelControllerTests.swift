//
//  ModelControllerTests.swift
//  ActionsTests
//
//  Created by Josh Rutheiser on 12/31/22.
//

import XCTest
@testable import Actions

final class ModelControllerTests: XCTestCase {
    var userId: String!
    var databaseWriter: DatabaseWriter!
    var databaseReader: DatabaseReader!
    var modelController: ModelController!
    var testPath: String!
    var session: String!
    
    override func setUp() async throws {
        databaseWriter = DatabaseWriter()
        databaseReader = DatabaseReader()
        userId = UUID().uuidString
        session = UUID().uuidString
        
        let testId = try databaseWriter.create(as: Test.self, Test(userId, name, session))
        try await databaseWriter.execute()
        
        testPath = "tests/\(testId)/"
        databaseWriter.setRootPath(testPath)
        databaseReader.setRootPath(testPath)
        
        modelController = ModelController(session, databaseReader, databaseWriter)
    }
    
    func testCreateNewUser() async throws {
        try await modelController.setupUser(userId)
        let user = await modelController.data.user
        XCTAssert(user!.userId == userId)
    }
    
    
}
