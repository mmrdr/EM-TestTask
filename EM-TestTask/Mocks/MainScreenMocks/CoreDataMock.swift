//
//  CoreDataMock.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

final class CoreDataMock: CoreDataProtocol {
    var storageCount: Int
    var fetchTaskResult: TaskEntity?
    var fetchAllTasksResult: [TaskEntity] = []
    var fetchAllTrashTasksResult: [DeletedTaskEntity] = []
    var createTaskFromDTOResult: [TaskDTO] = []
    var createTaskResult: [Task] = []
    var updateTaskResult: [Task] = []
    var newTaskId: Int64 = 1000
    var deleteTaskResult: [Int64] = []
    var fetchTrashTaskResult: DeletedTaskEntity?
    var createTrashTaskResult: [Task] = []
    var deleteTraskTaskResult: [Int64] = []
    
    init(storageCount: Int = 0) {
        self.storageCount = storageCount
    }
    
    func fetchTask(_ taskId: Int64) -> TaskEntity? { fetchTaskResult }
    
    func fetchAllTasks() -> [TaskEntity] { fetchAllTasksResult }
    
    func fetchAllTrashTasks() -> [DeletedTaskEntity] { fetchAllTrashTasksResult }
    
    func createTask(_ task: TaskDTO) { createTaskFromDTOResult.append(task) }
    
    func createTask(_ task: Task) { createTaskResult.append(task) }
    
    func updateTask(_ task: Task) { updateTaskResult.append(task) }
    
    func getStorageCount() -> Int { storageCount }
    
    func getNewTaskId() -> Int64 { newTaskId }
    
    func deleteTask(_ taskId: Int64) { deleteTaskResult.append(taskId) }
    
    func deleteAll() {
        fetchAllTasksResult.removeAll()
        fetchAllTrashTasksResult.removeAll()
        createTaskFromDTOResult.removeAll()
        createTaskResult.removeAll()
        updateTaskResult.removeAll()
        deleteTaskResult.removeAll()
        createTrashTaskResult.removeAll()
        deleteTraskTaskResult.removeAll()
    }
    
    func fetchTrashTask(_ taskId: Int64) -> DeletedTaskEntity? { fetchTrashTaskResult }
    
    func createTrashTask(_ task: Task) { createTrashTaskResult.append(task) }
    
    func deleteTrashTask(_ taskId: Int64) { deleteTraskTaskResult.append(taskId) }
    
    
}
