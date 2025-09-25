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

    func testSaveTaskSuccess() throws {
        
    }
    
    func testSaveTaskFailed() throws {
        
    }
    
    func testUpdateTaskSuccess() throws {
        
    }
    
    func testUpdateTaskFailed() throws {
        
    }
    
}
