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

    func testLoadTasksSuccess() throws {
        
    }
    
    func testLoadTasksFailed() throws {
        
    }
    
    func testRestoreTaskSuccess() throws {
        
    }
    
    func testRestoreTaskFailed() throws {
        
    }
    
    func testDeleteTaskSucces() throws {
        
    }
    
    func testDeleteTaskFailed() throws {
        
    }
}
