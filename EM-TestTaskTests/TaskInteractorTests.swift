//
//  TaskInteractorTests.swift
//  EM-TestTaskTests
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import XCTest

@testable import EM_TestTask
final class TaskInteractorTests: XCTestCase {
    
    var coreData: CoreDataMock!
    var networkService: NetworkServiceMock!
    var interactor: TaskInteractorProtocol!
    
    override func setUpWithError() throws {
        coreData = CoreDataMock(storageCount: 10)
        networkService = NetworkServiceMock()
        interactor = TaskInteractor(coreData: coreData, networkService: networkService)
    }
    
    override func tearDownWithError() throws {
        coreData = nil
        networkService = nil
        interactor = nil
    }
    
    func testSaveTaskSuccess() throws {
        coreData.newTaskId = 10
        let newTaskId = coreData.newTaskId
        let request = TaskCreateDTO(todo: "X", description: "X")
        let response = TaskDTO(id: 1, todo: "X", completed: false, userId: 1)
        networkService.enqueueResult(Result<TaskDTO, Error>.success(response))
        
        let createdExp = expectation(forNotification: .tasksCreatedEvent, object: nil) { notification in
            guard let task = notification.userInfo?["task"] as? Task else { return false }
            return task.id == newTaskId && task.todo == "X" && task.description == "X" && task.completed == false && task.userId == 1
        }
        
        let startAnimExp = expectation(forNotification: .startAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == newTaskId
        }
        
        let stopAnimExp = expectation(forNotification: .stopAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == newTaskId
        }
        
        let idUpdatedExp = expectation(forNotification: .taskIdUpdatedEvent, object: nil) { notification in
            guard let task = notification.userInfo?["task"] as? Task else { return false }
            return task.id == response.id && task.todo == "X" && task.description == "X" && task.completed == false && task.userId == 1
        }
        
        interactor.saveTask(request)
        
        wait(for: [createdExp, startAnimExp], timeout: 2.0)
        
        guard case let .request(endpoint, method, query, bodyType, _)? = networkService.calls.first else {
            return XCTFail("No HTTP call recorded")
        }
        
        XCTAssertEqual(endpoint, Endpoints.add.rawValue)
        XCTAssertEqual(method, .post)
        XCTAssertNil(query)
        XCTAssertEqual(bodyType, "TaskCreateRequest")
        
        wait(for: [stopAnimExp, idUpdatedExp], timeout: 2.0)
    }
    
    func testSaveTaskFailed() throws {
        let newTaskId = coreData.newTaskId
        let request = TaskCreateDTO(todo: "XFAIL", description: "XFAIL")
        let error = NSError(domain: "networkService", code: 500)
        networkService.enqueueResult(Result<TaskDTO, Error>.failure(error))
        
        let createdExp = expectation(forNotification: .tasksCreatedEvent, object: nil) { notification in
            guard let task = notification.userInfo?["task"] as? Task else { return false }
            return task.id == newTaskId && task.todo == "XFAIL" && task.description == "XFAIL" && task.completed == false && task.userId == 1
        }
        
        let startAnimExp = expectation(forNotification: .startAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == newTaskId
        }
        
        let stopAnimExp = expectation(forNotification: .stopAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == newTaskId
        }
        
        let showErrorExp = expectation(forNotification: .showErrorEvent, object: nil) { notification in
            let id = (notification.userInfo?["task"] as? Int64) == newTaskId
            let err = (notification.userInfo?["error"] as? Error) != nil
            return id && err
        }
        
        interactor.saveTask(request)
        
        wait(for: [createdExp, startAnimExp], timeout: 2.0)
        
        guard case let .request(endpoint, method, query, bodyType, _)? = networkService.calls.first else {
            return XCTFail("No HTTP call recorded")
        }
        
        XCTAssertEqual(endpoint, Endpoints.add.rawValue)
        XCTAssertEqual(method, .post)
        XCTAssertNil(query)
        XCTAssertEqual(bodyType, "TaskCreateRequest")
        
        wait(for: [stopAnimExp, showErrorExp], timeout: 2.0)

    }
    
    func testUpdateTaskSuccess() throws {
        let task = Task(id: 1, todo: "X", description: "X", completed: false, userId: 1, createdAt: Date())
        
        let updatedExpectation = expectation(forNotification: .taskUpdatedEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Task) == task
        }
        
        interactor.updateTask(task)
        
        XCTAssertEqual(coreData.updateTaskResult.count, 1)
        XCTAssertEqual(coreData.updateTaskResult[0].id, 1)
        XCTAssertEqual(coreData.updateTaskResult[0].todo, "X")
        XCTAssertEqual(coreData.updateTaskResult[0].description, "X")
        XCTAssertEqual(coreData.updateTaskResult[0].completed, false)
        XCTAssertEqual(coreData.updateTaskResult[0].userId, 1)
        
        wait(for: [updatedExpectation], timeout: 2.0)
    }
}
