//
//  TrashHistoryInteractor.swift
//  EM-TestTaskTests
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import XCTest

@testable import EM_TestTask
final class TrashHistoryInteractorTests: XCTestCase {
    
    var coreData: CoreDataMock!
    var networkService: NetworkServiceMock!
    var interactor: TrashHistoryInteractorProtocol!

    override func setUpWithError() throws {
        coreData = CoreDataMock(storageCount: 10)
        networkService = NetworkServiceMock()
        interactor = TrashHistoryInteractor(coreData: coreData, networkService: networkService)
    }

    override func tearDownWithError() throws {
        coreData = nil
        networkService = nil
        interactor = nil
    }
    
    func testRestoreTaskSuccess() throws {
        let task = Task(id: 1, todo: "X", description: "X", completed: false, userId: 1, createdAt: Date())
        let response = TaskDTO(id: 1, todo: "X", completed: false, userId: 1)
        networkService.enqueueResult((Result<TaskDTO, Error>.success(response)))
        
        let createdExp = expectation(forNotification: .tasksCreatedEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Task) == task
        }
        
        let startAnimExp = expectation(forNotification: .startAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == 1
        }

        let stopAnimExp = expectation(forNotification: .stopAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == 1
        }
        
        let updatedIdExp = expectation(forNotification: .taskIdUpdatedEvent, object: nil) { notification in
            guard let task = notification.userInfo?["task"] as? Task else { return false }
            return task.id == 1 && task.todo == "X" && task.description == "X" && task.completed == false && task.userId == 1
        }

        interactor.restoreTask(task)

        wait(for: [createdExp, startAnimExp], timeout: 2.0)

        guard case let .request(endpoint, method, query, bodyType, headers)? = networkService.calls.first else {
            return XCTFail("No network call recorded")
        }
        
        XCTAssertEqual(endpoint, Endpoints.add.rawValue)
        XCTAssertEqual(method, .post)
        XCTAssertNil(query)
        XCTAssertEqual(bodyType, "TaskCreateRequest")
        XCTAssertNil(headers)

        wait(for: [stopAnimExp, updatedIdExp], timeout: 2.0)

        XCTAssertEqual(coreData.deleteTraskTaskResult.count, 1)
    }
    
    func testRestoreTaskFailed() throws {
        let task = Task(id: 1, todo: "X", description: "X", completed: false, userId: 1, createdAt: Date())
        let error = NSError(domain: "networkService", code: 500)
        networkService.enqueueResult((Result<TaskDTO, Error>.failure(error)))
        
        let createdExp = expectation(forNotification: .tasksCreatedEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Task) == task
        }
        
        let startAnimExp = expectation(forNotification: .startAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == 1
        }

        let stopAnimExp = expectation(forNotification: .stopAnimationEvent, object: nil) { notification in
            (notification.userInfo?["task"] as? Int64) == 1
        }
        
        let errorExp = expectation(forNotification: .showErrorEvent, object: nil) { notification in
            let id = (notification.userInfo?["task"] as? Int64) == 1
            let err = (notification.userInfo?["error"] as? Error) != nil
            return id && err
        }

        interactor.restoreTask(task)

        wait(for: [createdExp, startAnimExp], timeout: 2.0)

        guard case let .request(endpoint, method, query, bodyType, headers)? = networkService.calls.first else {
            return XCTFail("No network call recorded")
        }
        
        XCTAssertEqual(endpoint, Endpoints.add.rawValue)
        XCTAssertEqual(method, .post)
        XCTAssertNil(query)
        XCTAssertEqual(bodyType, "TaskCreateRequest")
        XCTAssertNil(headers)

        wait(for: [stopAnimExp, errorExp], timeout: 2.0)
    }
    
    func testDeleteTaskSucces() throws {
        let task = Task(id: 1, todo: "X", description: "X", completed: false, userId: 1, createdAt: Date())

        interactor.deleteTask(task)

        XCTAssertEqual(coreData.deleteTraskTaskResult, [1])
    }
}
