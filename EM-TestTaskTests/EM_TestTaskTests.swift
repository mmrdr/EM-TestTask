//
//  EM_TestTaskTests.swift
//  EM-TestTaskTests
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import XCTest

@testable import EM_TestTask
final class EM_TestTaskTests: XCTestCase {
    
    var coreData: CoreDataMock!
    var networkService: NetworkServiceMock!
    var interactor: MainInteractorProtocol!

    override func setUpWithError() throws {
        coreData = CoreDataMock(storageCount: 10)
        networkService = NetworkServiceMock()
        interactor = MainInteractor(coreData: coreData, networkService: networkService)
    }

    override func tearDownWithError() throws {
        coreData = nil
        networkService = nil
        interactor = nil
    }

    func testLoadAllTasksFromCoreData() throws {
        coreData.fetchAllTasksResult = [TaskEntity(), TaskEntity()]
        let res = interactor.loadAllTasksFromCoreData()
        XCTAssertEqual(res.count, 2)
    }
    
    /// в dto неважно что id не тот
    func testCreateTaskSuccess() throws {
        let task = Task(id: 1, todo: "X2", description: "X1", completed: false, userId: 1, createdAt: Date())
        let dto = TaskDTO(id: 2, todo: "X2", completed: false, userId: 1)
        networkService.enqueueResult(Result<TaskDTO, Error>.success(dto))
        
        let expectation = expectation(description: "CreateTaskSuccess")
        var result: Result<TaskDTO, Error>?
        interactor.createTask(task) { res in
            result = res
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0) // если дольше 2 секунд то тест тоже не пройден(чините сервер)
        
        guard case let .request(endpoint, method, _, bodyType, _)? = networkService.calls.first else {
            return XCTFail("no network call")
        }
        
        XCTAssertEqual(endpoint, Endpoints.add.rawValue)
        XCTAssertEqual(method, .post)
        XCTAssertEqual(bodyType, "TaskCreateRequest")
        XCTAssertEqual(coreData.createTaskResult.count, 1)
        
        XCTAssertEqual(task.todo, dto.todo)
        XCTAssertEqual(task.completed, dto.completed)
        XCTAssertEqual(task.userId, dto.userId)
        
        let coreDataTask = coreData.createTaskResult[0]
        XCTAssertEqual(coreDataTask.todo, dto.todo)
        XCTAssertEqual(coreDataTask.description, task.description)
        XCTAssertEqual(coreDataTask.completed, dto.completed)
        XCTAssertEqual(coreDataTask.userId, dto.userId)
        
        
        switch result {
        case .success(let response):
            XCTAssertEqual(response, dto)
        case .failure(_):
            XCTFail("Expected success")
        case .none:
            XCTFail("Expected success")
        }
    }
    
    func testCreateTestFailed() throws {
        let input = Task(id: 3, todo: "X3", description: "X3", completed: false, userId: -1, createdAt: Date())
        networkService.enqueueResult(Result<TaskDTO, Error>.failure(NSError(domain: "networkService", code: 404)))

        let expectation = expectation(description: "CreateTaskFail")
        var result: Result<TaskDTO, Error>?
        interactor.createTask(input) { res in
            result = res
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(coreData.createTaskResult.isEmpty)
        
        switch result {
        case .success(_):
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 404)
        case .none:
            XCTFail("Expected failure")
        }
    }

    func testUpdateTaskSuccess() throws {
        let task = Task(id: 4, todo: "X4", description: "X4", completed: false, userId: 1, createdAt: Date())
        networkService.enqueueResult(Result<DeletedTask, Error>.success(DeletedTask(id: 4, todo: "X4", completed: false, userId: 4, isDeleted: true, deletedOn: Date())))

        let expectation = expectation(description: "UpdateTaskSuccess")
        interactor.updateTask(task)
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(coreData.updateTaskResult.count, 1)
        XCTAssertEqual(coreData.updateTaskResult.first?.id, 4)
        XCTAssertEqual(coreData.updateTaskResult.first?.todo, "X4")
        XCTAssertEqual(coreData.updateTaskResult.first?.description, "X4")
        XCTAssertEqual(coreData.updateTaskResult.first?.userId, 1)
        XCTAssertEqual(coreData.updateTaskResult.first?.completed, false)
    }
    
    func testUpdateTaskFailed() throws {
        let task = Task(id: 5, todo: "X5", description: "X5", completed: true, userId: 1, createdAt: Date())
        networkService.enqueueResult(Result<DeletedTask, Error>.failure(NSError(domain: "networkService", code: 500)))

        let expectation = expectation(description: "UpdateTaskFailed")
        interactor.updateTask(task)
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(coreData.updateTaskResult.count, 2)
        XCTAssertEqual(coreData.updateTaskResult[0].completed, true)
        XCTAssertEqual(coreData.updateTaskResult[1].completed, false)
    }
    
    func testDeleteTaskSuccess() throws {
        let task = Task(id: 6, todo: "X6", description: "X6", completed: false, userId: 1, createdAt: Date())
        networkService.enqueueResult(Result<DeletedTask, Error>.success(DeletedTask(id: 6, todo: "X6", completed: false, userId: 1, isDeleted: true, deletedOn: Date())))

        let expectation = expectation(description: "DeleteTaskSuccess")
        var result: Result<Void, Error>?
        interactor.deleteTask(task) { res in
            result = res
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(coreData.deleteTaskResult, [6])
        XCTAssertEqual(coreData.createTrashTaskResult.count, 1)
        XCTAssertEqual(coreData.createTrashTaskResult[0].id, 6)
        XCTAssertTrue(coreData.createTaskResult.isEmpty)
        XCTAssertTrue(coreData.deleteTraskTaskResult.isEmpty)

        switch result {
        case .success(_):
            break
        case .failure(_):
            XCTFail("Expected success")
        case .none:
            XCTFail("Expected success")
        }
    }
    
    func testDeleteTaskFailed() throws {
        let task = Task(id: 7, todo: "X7", description: "X7", completed: false, userId: 1, createdAt: Date())
        networkService.enqueueResult(Result<DeletedTask, Error>.failure(NSError(domain: "networkService", code: 503)))

        let createdExp = expectation(forNotification: .tasksCreatedEvent, object: nil) { note in
            (note.userInfo?["task"] as? Task)?.id == 7
        }
        let trashDeletedExp = expectation(forNotification: .trashTaskDeletedEvent, object: nil) { note in
            (note.userInfo?["task"] as? Task)?.id == 7
        }

        let completionExp = expectation(description: "DeleteTaskFailed")
        var result: Result<Void, Error>?
        interactor.deleteTask(task) { res in
            result = res
            completionExp.fulfill()
        }

        wait(for: [createdExp, trashDeletedExp, completionExp], timeout: 2.0)

        XCTAssertEqual(coreData.deleteTaskResult.first, 7)
        XCTAssertEqual(coreData.createTrashTaskResult.first?.id, 7)

        XCTAssertEqual(coreData.createTaskResult.first?.id, 7)
        XCTAssertEqual(coreData.deleteTraskTaskResult.first, 7)

        switch result {
        case .success(_):
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 503)
        case .none:
            XCTFail("Expected failure")
        }
    }
    
    func testLoadFirstPageSuccess() throws {
        let todos = [
            TaskDTO(id: 1, todo: "A", completed: false, userId: 1),
            TaskDTO(id: 2, todo: "B", completed: true, userId: 1)
        ]
        let response = Tasks(todos: todos, total: 150, skip: 0, limit: 30)
        networkService.enqueueResult(Result<Tasks, Error>.success(response))

        let expectation = expectation(description: "LoadFirstPageSuccess")
        var result: Result<Tasks, Error>?
        interactor.loadFirstPage { res in
            result = res
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        guard case let .request(endpoint, method, _, _, _)? = networkService.calls.first else {
            return XCTFail("no call recorded")
        }
        
        XCTAssertEqual(endpoint, "")
        XCTAssertEqual(method, .get)

        XCTAssertEqual(coreData.createTaskFromDTOResult.count, 2)
        XCTAssertEqual(coreData.createTaskFromDTOResult[0].id, 1)
        XCTAssertEqual(coreData.createTaskFromDTOResult[1].id, 2)

        switch result {
        case .success(let response):
            XCTAssertEqual(response.todos.count, 2)
        case .failure(_):
            XCTFail("Expected Success")
        case .none:
            XCTFail("Expected Success")
        }
    }
    
    func testLoadFirstPageFailed() throws {
        networkService.enqueueResult(Result<Tasks, Error>.failure(NSError(domain: "net", code: 500)))

        let expectation = expectation(description: "LoadFirstPageFailed")
        var result: Result<Tasks, Error>?
        interactor.loadFirstPage { res in
            result = res
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(coreData.createTaskResult.isEmpty)
        
        switch result {
        case .success(_):
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 500)
        case .none:
            XCTFail("Expected failure")
        }
    }
}
