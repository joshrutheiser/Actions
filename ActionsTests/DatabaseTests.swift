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
    
    override func setUpWithError() throws {
        databaseWriter = DatabaseWriter()
        databaseReader = DatabaseReader()
        userId = UUID().uuidString
        
        let semaphore = DispatchSemaphore(value: 1)
        let testId = try databaseWriter.create(as: Test.self, Test(userId, name))
        DispatchQueue.main.async { [self] in
            databaseWriter.execute() {
                semaphore.signal()
            }
        }
        semaphore.wait()
        
        testPath = "tests/\(testId)/"
        databaseWriter.setRootPath(rootPath: testPath)
    }

    override func tearDownWithError() throws {
        
    }
    
    //MARK: - User not created

    func testUserNotCreated() throws {
        let expectation = expectation(description: #function)
        let query = QueryBuilder(User.self, rootPath: testPath)
            .user(userId)
            .build()
        
        databaseReader.getDocuments(query, as: User.self) { results in
            XCTAssertTrue(results.isEmpty)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    //MARK: - Create user
    
    func testCreateUser() throws {
        let exp = expectation(description: #function)
        
        let id = try! databaseWriter.create(as: User.self, User(userId))
        databaseWriter.execute() { [self] in
            
            let query = QueryBuilder(User.self, rootPath: testPath)
                .user(userId)
                .build()
            
            databaseReader.getDocuments(query, as: User.self) { [self] results in
                XCTAssert(results.count == 1)
                XCTAssertEqual(results.first!.change, .Update)
                XCTAssertEqual(results.first!.object.id, id)
                XCTAssertEqual(results.first!.object.userId, userId)
                exp.fulfill()
            }
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    //MARK: - User listener
    
    func testUserListener() throws {
        let id = try! databaseWriter.create(as: User.self, User(userId))
        
        let exp = expectation(description: #function)
        let query = QueryBuilder(User.self, rootPath: testPath)
            .user(userId)
            .build()

        databaseReader.listenDocuments(query, as: User.self) { [self] results in
            if results.isEmpty == false {
                XCTAssert(results.count == 1)
                XCTAssertEqual(results.first!.change, .Update)
                XCTAssertEqual(results.first!.object.id, id)
                XCTAssertEqual(results.first!.object.userId, userId)
                exp.fulfill()
            }
        }
        
        let exp2 = expectation(description: #function + "2")
        databaseWriter.execute() {
            exp2.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    //MARK: - User update
    
    func testUserUpdate() throws {
        let exp1 = expectation(description: #function)
        var user = User(userId)
        let id = try! databaseWriter.create(as: User.self, user)
        databaseWriter.execute() {
            exp1.fulfill()
        }
        
        user.id = id
        user.currentMode = .Work
        try! databaseWriter.update(as: User.self, user)

        let query = QueryBuilder(User.self, rootPath: testPath)
            .user(userId)
            .build()

        let exp2 = expectation(description: #function + "2")
        var count = 0
        databaseReader.listenDocuments(query, as: User.self) { [self] results in
            count += 1
            if count == 2 {
                XCTAssert(results.count == 1)
                XCTAssertEqual(results.first!.change, .Update)
                XCTAssertEqual(results.first!.object.id, id)
                XCTAssertEqual(results.first!.object.userId, userId)
                XCTAssertEqual(results.first!.object.currentMode, .Work)
                exp2.fulfill()
            }
        }
        

        let exp3 = expectation(description: #function + "3")
        databaseWriter.execute() {
            exp3.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    //MARK: - Create multiple actions
    
    func testCreateMultipleActions() throws {
        let exp = expectation(description: #function)
        
        let id1 = try! databaseWriter.create(as: Action.self, Action(userId, "1"))
        let id2 = try! databaseWriter.create(as: Action.self, Action(userId, "2"))
        let id3 = try! databaseWriter.create(as: Action.self, Action(userId, "3"))
        databaseWriter.execute() { [self] in
            
            let query = QueryBuilder(Action.self, rootPath: testPath)
                .user(userId)
                .build()
            
            databaseReader.getDocuments(query, as: Action.self) { [self] results in
                XCTAssert(results.count == 3)
                for result in results {
                    XCTAssertEqual(result.change, .Update)
                    XCTAssert(Set([id1, id2, id3]).contains(result.object.id))
                    XCTAssertEqual(result.object.userId, userId)
                }

                exp.fulfill()
            }
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
