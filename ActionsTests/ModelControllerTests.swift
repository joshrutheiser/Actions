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
    
    override func setUpWithError() throws {
        databaseWriter = DatabaseWriter()
        databaseReader = DatabaseReader()
        userId = UUID().uuidString
        session = UUID().uuidString
        
        let semaphore = DispatchSemaphore(value: 1)
        let testId = try databaseWriter.create(as: Test.self, Test(userId, name, session))
        DispatchQueue.main.async { [self] in
            databaseWriter.execute() {
                semaphore.signal()
            }
        }
        semaphore.wait()
        
        testPath = "tests/\(testId)/"
        databaseWriter.setRootPath(testPath)
        databaseReader.setRootPath(testPath)
        
        modelController = ModelController(session, databaseReader, databaseWriter)
    }
    
    override func tearDownWithError() throws {
    }
    
    func testUserSameSessionUpdate() throws {
        let expectation = expectation(description: #function)
        modelController.setupUser(userId)
        
        waitForExpectations(timeout: 300)
    }
}
