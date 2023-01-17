//
//  ModelControllerTests.swift
//  ActionsTests
//
//  Created by Josh Rutheiser on 12/31/22.
//

import XCTest
@testable import Actions

final class ModelControllerTests: XCTestCase, LocalCacheObserver {
    var config: DataSyncConfig!
    var model: ModelController!
    var testPath: String!
    var userId: String!
    var session: String!
    
    override func setUp() async throws {
        let databaseWriter = DatabaseWriter()
        let databaseReader = DatabaseReader()
        session = UUID().uuidString
        userId = UUID().uuidString
        
        // create test parent doc
        let testId = try databaseWriter.create(as: Test.self, Test(userId, name, session))
        try await databaseWriter.commit()
        
        testPath = "tests/\(testId)/"
        databaseWriter.setRootPath(testPath)
        databaseReader.setRootPath(testPath)
        
        let config = DataSyncConfig (
            delegate: self,
            session: session,
            userId: userId,
            rootPath: testPath
        )
        
        model = ModelController(config)
        try await model.startListening()
    }
    
    func dataUpdated() {
        print("data updated")
    }
    
    func testCreateNewUser() throws {
        let user = try model.read.getUser()
        XCTAssert(user.userId == userId)
    }
    
    //MARK: - Create action
    
    func testCreateActionInBacklog() async throws {
        let actionId = try await model.write.createAction("Testing")!
        let user = try model.read.getUser()
        let action = try model.read.getAction(actionId)
        let backlog = try model.read.getBacklog()
        XCTAssertNotNil(user)
        XCTAssertNotNil(action)
        XCTAssertNotNil(backlog)
        XCTAssertEqual(backlog.count, 1)
        XCTAssertEqual(backlog.first, actionId)
    }
    
    func testCreateActionInBacklog_Multiple() async throws {
        let id1 = try await model.write.createAction("1")!
        let id2 = try await model.write.createAction("2")!
        let id3 = try await model.write.createAction("3")!
        let backlog = try model.read.getBacklog()
        XCTAssertNotNil(backlog)
        XCTAssertEqual(backlog.count, 3)
        XCTAssertEqual(backlog[0], id3)
        XCTAssertEqual(backlog[1], id2)
        XCTAssertEqual(backlog[2], id1)
    }
    
    func testCreateRankedActionInBacklog() async throws {
        let id1 = try await model.write.createAction("1")!
        let id2 = try await model.write.createAction("2")!
        let id3 = try await model.write.createAction("3")!
        let id4 = try await model.write.createAction("4", rank: 2)
        let backlog = try model.read.getBacklog()
        XCTAssertNotNil(backlog)
        XCTAssertEqual(backlog.count, 4)
        XCTAssertEqual(backlog[0], id3)
        XCTAssertEqual(backlog[1], id2)
        XCTAssertEqual(backlog[2], id4)
        XCTAssertEqual(backlog[3], id1)
    }
    
    func testCreateRankedActionInBacklog_OutOfBounds() async throws {
        let _ = try await model.write.createAction("1")!
        
        do {
            let _ = try await model.write.createAction("2", rank: 3)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func testCreateParentChildAction() async throws {
        let id1 = try await model.write.createAction("1")!
        let id2 = try await model.write.createAction("a", parentId: id1)!
        let id3 = try await model.write.createAction("b", parentId: id1, rank: 1)!
        
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 1)
        XCTAssertEqual(backlog[0], id1)
        
        let parent = try model.read.getAction(id1)
        let child1 = try model.read.getAction(id2)
        let child2 = try model.read.getAction(id3)
        XCTAssertEqual(parent.childIds.count, 2)
        XCTAssertEqual(parent.childIds[0], id2)
        XCTAssertEqual(parent.childIds[1], id3)
        XCTAssertEqual(child1.parentId!, id1)
        XCTAssertEqual(child2.parentId!, id1)
    }
    
    //MARK: - Move action
    
    func testMoveActionInBacklog() async throws {
        let id1 = try await model.write.createAction("1", rank: 0)!
        let id2 = try await model.write.createAction("2", rank: 1)!
        let id3 = try await model.write.createAction("3", rank: 2)!
        
        try await model.write.moveAction(id3, rank: 0) // 0=id3, 1=id1, 2=id2
        
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog[0], id3)
        XCTAssertEqual(backlog[1], id1)
        XCTAssertEqual(backlog[2], id2)
    }
    
    func testMoveActionOutOfBounds() async throws {
        let id1 = try await model.write.createAction("1", rank: 0)!
        
        do {
            try await model.write.moveAction(id1, rank: 1)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func testMoveChildInParent() async throws {
        let id = try await model.write.createAction("Parent")!
        let id1 = try await model.write
            .createAction("1", parentId: id, rank: 0)!
        let id2 = try await model.write
            .createAction("2", parentId: id, rank: 1)!
        let id3 = try await model.write
            .createAction("3", parentId: id, rank: 2)!
        
        try await model.write.moveAction(id3, rank: 1) // 0=id1, 1=id3, 2=id2
        
        let children = try model.read.getChildActionIds(id)
        XCTAssertEqual(children[0], id1)
        XCTAssertEqual(children[1], id3)
        XCTAssertEqual(children[2], id2)
    }
    
    func testMoveParentToChild() async throws {
        let idA = try await model.write.createAction("ParentA")!
        let idB = try await model.write.createAction("ParentB")!
        let id1 = try await model.write
            .createAction("1", parentId: idA, rank: 0)!
        let id2 = try await model.write
            .createAction("2", parentId: idA, rank: 1)!
        let id3 = try await model.write
            .createAction("3", parentId: idA, rank: 2)!
        
        try await model.write.moveActionTo(idB, parentId: idA, rank: 1)
        
        let children = try model.read.getChildActionIds(idA)
        XCTAssertEqual(children[0], id1)
        XCTAssertEqual(children[1], idB) // ParentB
        XCTAssertEqual(children[2], id2)
        XCTAssertEqual(children[3], id3)
        
        // check that ParentB is no longer in backlog
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 1)
        XCTAssertEqual(backlog[0], idA)
        
        // check that parent of ParentB is ParentA
        let parentB = try model.read.getAction(idB)
        XCTAssertEqual(parentB.parentId, idA)
    }
    
    func testMoveChildToParent() async throws {
        let idA = try await model.write.createAction("ParentA")!
        let idB = try await model.write.createAction("ParentB")!
        let id1 = try await model.write
            .createAction("1", parentId: idA, rank: 0)!
        let id2 = try await model.write
            .createAction("2", parentId: idA, rank: 1)!
        let id3 = try await model.write
            .createAction("3", parentId: idA, rank: 2)!
        
        try await model.write.moveActionTo(id3, parentId: idB)
        
        let childrenA = try model.read.getChildActionIds(idA)
        XCTAssertEqual(childrenA.count, 2)
        XCTAssertEqual(childrenA[0], id1)
        XCTAssertEqual(childrenA[1], id2)
        
        let childrenB = try model.read.getChildActionIds(idB)
        XCTAssertEqual(childrenB.count, 1)
        XCTAssertEqual(childrenB[0], id3)
        
        // check that parent of id3 is ParentB
        let action3 = try model.read.getAction(id3)
        XCTAssertEqual(action3.parentId, idB)
    }
    
    func testMoveChildToBacklog() async throws {
        let idA = try await model.write.createAction("ParentA")!
        let id1 = try await model.write
            .createAction("1", parentId: idA, rank: 0)!
        let id2 = try await model.write
            .createAction("2", parentId: idA, rank: 1)!
        let id3 = try await model.write
            .createAction("3", parentId: idA, rank: 2)!
        
        try await model.write.moveActionTo(id3, parentId: nil)
        
        let childrenA = try model.read.getChildActionIds(idA)
        XCTAssertEqual(childrenA.count, 2)
        XCTAssertEqual(childrenA[0], id1)
        XCTAssertEqual(childrenA[1], id2)
        
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 2)
        XCTAssertEqual(backlog[0], id3)
        XCTAssertEqual(backlog[1], idA)
        
        // check that parent of id3 is nil
        let action3 = try model.read.getAction(id3)
        XCTAssertEqual(action3.parentId, nil)
    }
    
    //MARK: - Complete action
    
    func testCompleteBacklogAction() async throws {
        let id1 = try await model.write.createAction("1")!
        try await model.write.completeAction(id1)
        
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 0)
        
        let action1 = try model.read.getAction(id1)
        XCTAssertTrue(action1.isCompleted)
        XCTAssertNotNil(action1.completedDate)
    }
    
    func testCompleteParentAction() async throws {
        let idA = try await model.write.createAction("A")!
        let id1 = try await model.write.createAction("1", parentId: idA)!
        let id2 = try await model.write.createAction("2", parentId: idA)!
        try await model.write.completeAction(idA)
                
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 0)
        
        let action1 = try model.read.getAction(id1)
        XCTAssertTrue(action1.isCompleted)
        XCTAssertNotNil(action1.completedDate)
        
        let action2 = try model.read.getAction(id2)
        XCTAssertTrue(action2.isCompleted)
        XCTAssertNotNil(action2.completedDate)
    }
    
    func testCompleteChildAction() async throws {
        let idA = try await model.write.createAction("A")!
        let id1 = try await model.write.createAction("1", parentId: idA)!
        let id2 = try await model.write.createAction("2", parentId: idA)!
        try await model.write.completeAction(id1)
                
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 1)
        
        let children = try model.read.getChildActionIds(idA)
        XCTAssertEqual(children.count, 1)
        XCTAssertEqual(children[0], id2)
    }
    
    //MARK: - Delete action
    
    func testDeleteBacklogAction() async throws {
        let id1 = try await model.write.createAction("1")!
        try await model.write.deleteAction(id1)
        
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 0)
        
        let action1 = try model.read.getAction(id1)
        XCTAssertTrue(action1.isDeleted)
        XCTAssertNotNil(action1.deletedDate)
    }
    
    func testDeleteParentAction() async throws {
        let idA = try await model.write.createAction("A")!
        let id1 = try await model.write.createAction("1", parentId: idA)!
        let id2 = try await model.write.createAction("2", parentId: idA)!
        try await model.write.deleteAction(idA)
                
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 0)
        
        let action1 = try model.read.getAction(id1)
        XCTAssertTrue(action1.isDeleted)
        XCTAssertNotNil(action1.deletedDate)
        
        let action2 = try model.read.getAction(id2)
        XCTAssertTrue(action2.isDeleted)
        XCTAssertNotNil(action2.deletedDate)
    }
    
    func testDeleteChildAction() async throws {
        let idA = try await model.write.createAction("A")!
        let id1 = try await model.write.createAction("1", parentId: idA)!
        let id2 = try await model.write.createAction("2", parentId: idA)!
        try await model.write.deleteAction(id1)
                
        let backlog = try model.read.getBacklog()
        XCTAssertEqual(backlog.count, 1)
        
        let children = try model.read.getChildActionIds(idA)
        XCTAssertEqual(children.count, 1)
        XCTAssertEqual(children[0], id2)
    }
    
    //MARK: - Save action text
    
    func testSaveActionText() async throws {
        let idA = try await model.write.createAction("A")!
        try await model.write.saveActionText(idA, "B")
        let action = try model.read.getAction(idA)
        XCTAssertEqual(action.text, "B")
    }
    
    //MARK: - Toggle mode
    
    func testToggleMode() async throws {
        let idA = try await model.write.createAction("A")!
        let userA = try model.read.getUser()
        let backlogA = userA.backlog["Personal"]!
        XCTAssertEqual(userA.currentMode, "Personal")
        XCTAssertEqual(backlogA[0], idA)
        XCTAssertEqual(backlogA.count, 1)
        
        try await model.write.toggleMode() // change from personal to work
        
        let idB = try await model.write.createAction("B")!
        let userB = try model.read.getUser()
        let backlogB = userB.backlog["Work"]!
        XCTAssertEqual(userB.currentMode, "Work")
        XCTAssertEqual(backlogB[0], idB)
        XCTAssertEqual(backlogB.count, 1)
        
        try await model.write.toggleMode() // change from work to personal

        let idC = try await model.write.createAction("C", rank: 1)!
        let userC = try model.read.getUser()
        let backlogC = userC.backlog["Personal"]!
        XCTAssertEqual(userC.currentMode, "Personal")
        XCTAssertEqual(backlogC[0], idA)
        XCTAssertEqual(backlogC[1], idC)
        XCTAssertEqual(backlogC.count, 2)
    }
    
    //MARK: - Skip
    
    func testSkip() async throws {
        let idA = try await model.write.createAction("A")!
        try await model.write.skip(idA)
        let action = try model.read.getAction(idA)
        XCTAssertEqual(action.skipped, 1)
        XCTAssertNotNil(action.lastSkipped)
        let firstSkipDate = action.lastSkipped!
        
        try await model.write.skip(idA)
        let action2 = try model.read.getAction(idA)
        XCTAssertEqual(action2.skipped, 2)
        XCTAssertNotNil(action.lastSkipped)
        XCTAssert(action2.lastSkipped! > firstSkipDate)
    }

    //MARK: - Schedule
    
    func testSchedule() async throws {
        let idA = try await model.write.createAction("A")!
        try await model.write.schedule(idA, Date())
        let action = try model.read.getAction(idA)
        XCTAssertNotNil(action.scheduledDate)
    }
    
    //MARK: - Enter
    
    func testEnterPressed() async throws {
        
    }
}
