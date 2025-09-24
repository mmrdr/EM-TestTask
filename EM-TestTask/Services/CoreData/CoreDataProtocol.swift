//
//  CoreDataProtocol.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

protocol CoreDataProtocol {
    func fetchTask(_ taskId: Int64) -> TaskEntity?
    func fetchAllTasks() -> [TaskEntity]
    func fetchAllTrashTasks() -> [DeletedTaskEntity]
    
    func createTask(_ task: TaskDTO)
    func createTask(_ task: Task)
    func updateTask(_ task: Task)
    
    func getNewTaskId() -> Int64
    
    func deleteTask(_ taskId: Int64)
    func deleteAll()
    
    func fetchTrashTask(_ taskId: Int64) -> DeletedTaskEntity?
    func createTrashTask(_ task: Task)
    func deleteTrashTask(_ taskId: Int64)
}
