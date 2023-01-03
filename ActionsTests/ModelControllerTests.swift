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
    var model: ModelController!
    var testPath: String!
    var session: String!
    
    override func setUp() async throws {
        databaseWriter = DatabaseWriter()
        databaseReader = DatabaseReader()
        userId = UUID().uuidString
        session = UUID().uuidString
        
        let testId = try databaseWriter.create(as: Test.self, Test(userId, name, session))
        try await databaseWriter.commit()
        
        testPath = "tests/\(testId)/"
        databaseWriter.setRootPath(testPath)
        databaseReader.setRootPath(testPath)
        
        model = ModelController(session, databaseReader, databaseWriter)
        try await model.setup(userId)
    }
    
    func testCreateNewUser() async throws {
        let user = await model.data.user!
        XCTAssert(user.userId == userId)
    }
    
    func testCreateActionInBacklog() async throws {
        let actionId = try await model.createAction("Testing")!
        let user = try await model.getUser()
        let action = try await model.getAction(actionId)
        let backlog = try await model.getBacklog()
        XCTAssertNotNil(user)
        XCTAssertNotNil(action)
        XCTAssertNotNil(backlog)
        XCTAssertEqual(backlog!.count, 1)
        XCTAssertEqual(backlog!.first, actionId)
    }
    
    func testCreateActionInBacklog_Multiple() async throws {
        let id1 = try await model.createAction("1")!
        let id2 = try await model.createAction("2")!
        let id3 = try await model.createAction("3")!
        let backlog = try await model.getBacklog()
        XCTAssertNotNil(backlog)
        XCTAssertEqual(backlog!.count, 3)
        XCTAssertEqual(backlog![0], id3)
        XCTAssertEqual(backlog![1], id2)
        XCTAssertEqual(backlog![2], id1)
    }
    
    func testCreateRankedActionInBacklog() async throws {
        let id1 = try await model.createAction("1")!
        let id2 = try await model.createAction("2")!
        let id3 = try await model.createAction("3")!
        let id4 = try await model.createAction("4", rank: 2)
        let backlog = try await model.getBacklog()
        XCTAssertNotNil(backlog)
        XCTAssertEqual(backlog!.count, 4)
        XCTAssertEqual(backlog![0], id3)
        XCTAssertEqual(backlog![1], id2)
        XCTAssertEqual(backlog![2], id4)
        XCTAssertEqual(backlog![3], id1)
    }
    
    func testCreateRankedActionInBacklog_OutOfBounds() async throws {
        let _ = try await model.createAction("1")!
        
        do {
            let _ = try await model.createAction("2", rank: 3)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func testCreateParentChildAction() async throws {
        let id1 = try await model.createAction("1")!
        let id2 = try await model.createAction("a", parentId: id1)!
        let id3 = try await model.createAction("b", parentId: id1, rank: 1)!
        
        let backlog = try await model.getBacklog()
        XCTAssertEqual(backlog!.count, 1)
        XCTAssertEqual(backlog![0], id1)
        
        let parent = try await model.getAction(id1)
        let child1 = try await model.getAction(id2)
        let child2 = try await model.getAction(id3)
        XCTAssertEqual(parent.childIds.count, 2)
        XCTAssertEqual(parent.childIds[0], id2)
        XCTAssertEqual(parent.childIds[1], id3)
        XCTAssertEqual(child1.parentId!, id1)
        XCTAssertEqual(child2.parentId!, id1)
    }
    
    
}
