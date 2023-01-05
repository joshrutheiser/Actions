//
//  ActionsTests.swift
//  ActionsTests
//
//  Created by Josh Rutheiser on 12/25/22.
//

import XCTest
import Firebase
@testable import Actions

class DatabaseTests: XCTestCase {
    var userId: String!
    var databaseWriter: DatabaseWriter!
    var databaseReader: DatabaseReader!
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
    }
    
    //MARK: - User not created

    func testUserNotCreated() async throws {
        let query = QueryBuilder(User.self)
            .whereField("userId", isEqualTo: userId)
        let results = try await databaseReader.getDocuments(query, as: User.self)
        XCTAssertTrue(results.isEmpty)
    }
    
    //MARK: - Create user
    
    func testCreateUser() async throws {
        let user = User(userId: userId, session: session)
        let id = try databaseWriter.create(as: User.self, user)
        try await databaseWriter.commit()
        
        let query = QueryBuilder(User.self)
            .whereField("userId", isEqualTo: userId)
        let results = try await databaseReader.getDocuments(query, as: User.self)
        
        XCTAssert(results.count == 1)
        XCTAssertEqual(results.first!.change, .Set)
        XCTAssertEqual(results.first!.object.id, id)
        XCTAssertEqual(results.first!.object.userId, userId)
    }
    
    //MARK: - User listener
    
    func testUserListener() async throws {
        let id = try databaseWriter.create(as: User.self, User(userId: userId, session: session))
        let query = QueryBuilder(User.self)
            .whereField("userId", isEqualTo: userId)
        
        let exp = expectation(description: #function)
        databaseReader.listenDocuments(query, as: User.self) { [self] results in
            if results.isEmpty == false {
                XCTAssert(results.count == 1)
                XCTAssertEqual(results.first!.change, .Set)
                XCTAssertEqual(results.first!.object.id, id)
                XCTAssertEqual(results.first!.object.userId, userId)
                exp.fulfill()
            }
        }
        
        try await databaseWriter.commit()
        await waitForExpectations(timeout: 5, handler: nil)
    }
    
    //MARK: - User update
    
    func testUserUpdate() async throws {
        var user = User(userId: userId, session: session)
        let id = try databaseWriter.create(as: User.self, user)
        try await databaseWriter.commit()

        user.id = id
        user.currentMode = Mode.Work.rawValue
        try databaseWriter.update(as: User.self, user)

        var count = 0
        let query = QueryBuilder(User.self)
            .whereField("userId", isEqualTo: userId)
        let exp = expectation(description: #function)
        databaseReader.listenDocuments(query, as: User.self) { [self] results in
            count += 1
            if count == 2 {
                XCTAssert(results.count == 1)
                XCTAssertEqual(results.first!.change, .Set)
                XCTAssertEqual(results.first!.object.id, id)
                XCTAssertEqual(results.first!.object.userId, userId)
                XCTAssertEqual(results.first!.object.currentMode, Mode.Work.rawValue)
                exp.fulfill()
            }
        }
        try await databaseWriter.commit()
        await waitForExpectations(timeout: 5, handler: nil)
    }

    //MARK: - Remove from listener

    func testRemoveFromListener() async throws {

        var action = Action("2", userId: userId, session: session)
        let _ = try databaseWriter.create(as: Action.self, Action("1", userId: userId, session: session))
        let id2 = try databaseWriter.create(as: Action.self, action)
        let _ = try databaseWriter.create(as: Action.self, Action("3", userId: userId, session: session))
        try await databaseWriter.commit()

        var count = 0
        let query = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: userId)
        let exp = expectation(description: #function)
        databaseReader.listenDocuments(query, as: Action.self) { results in
            count += 1
            if count == 2 {
                XCTAssertEqual(results.count, 1)
                XCTAssertEqual(results.first!.change, .Remove)
                XCTAssertEqual(results.first!.object.id, id2)
                exp.fulfill()
            }
        }

        action.id = id2
        action.userId = ""
        try databaseWriter.update(as: Action.self, action)
        try await databaseWriter.commit()
        
        await waitForExpectations(timeout: 5, handler: nil)
    }

    //MARK: Create multiple actions

    func testCreateMultipleActions() async throws {
        let id1 = try databaseWriter.create(as: Action.self, Action("1", userId: userId, session: session))
        let id2 = try databaseWriter.create(as: Action.self, Action("2", userId: userId, session: session))
        let id3 = try databaseWriter.create(as: Action.self, Action("3", userId: userId, session: session))
        try await databaseWriter.commit()

        let query = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: userId)
        let results = try await databaseReader.getDocuments(query, as: Action.self)
        XCTAssert(results.count == 3)
        for result in results {
            XCTAssertEqual(result.change, .Set)
            XCTAssert(Set([id1, id2, id3]).contains(result.object.id))
            XCTAssertEqual(result.object.userId, userId)
        }
    }

    //MARK: - Remove from get docs

    func testRemoveFromGetDocs() async throws {
        var action = Action("2", userId: userId, session: session)
        let id1 = try databaseWriter.create(as: Action.self, Action("1", userId: userId, session: session))
        let id2 = try databaseWriter.create(as: Action.self, action)
        let id3 = try databaseWriter.create(as: Action.self, Action("3", userId: userId, session: session))
        try await databaseWriter.commit()
        
        action.id = id2
        action.userId = ""
        try databaseWriter.update(as: Action.self, action)
        try await databaseWriter.commit()

        let query = QueryBuilder(Action.self)
            .whereField("userId", isEqualTo: userId)
        let results = try await databaseReader.getDocuments(query, as: Action.self)
        
        XCTAssertEqual(results.count, 2)
        for result in results {
            XCTAssertEqual(result.change, .Set)
            XCTAssert(Set([id1, id3]).contains(result.object.id))
            XCTAssertEqual(result.object.userId, userId)
        }

    }
}
