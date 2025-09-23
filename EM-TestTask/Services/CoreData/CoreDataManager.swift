//
//  CoreDataManager.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation
import CoreData

final class CoreDataManager: CoreDataProtocol {
    
    enum Models: String {
        case task = "TaskModel"
    }
    
    // MARK: - CRUD
    
    func fetchTask(_ taskId: Int64) -> TaskEntity? {
        let c = CoreDataStack.shared.viewContext(for: Models.task.rawValue)
        let r: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        r.predicate = NSPredicate(format: "id == %@", NSNumber(value: taskId))
        r.fetchLimit = 1
        return try? c.fetch(r).first
    }
    
    func fetchAllTasks() -> [TaskEntity] {
        let c = CoreDataStack.shared.viewContext(for: Models.task.rawValue)
        let r: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            return try c.fetch(r)
        } catch {
            debugPrint("Fetching tasks failed or empty")
            return []
        }
    }
    
    func createTask(_ taskDTO: TaskDTO) {
        let c = CoreDataStack.shared.viewContext(for: Models.task.rawValue)
        let task = TaskEntity(context: c)
        
        task.id = taskDTO.id
        task.todo = taskDTO.todo
        task.todoDescription = "No description provided"
        task.completed = taskDTO.completed
        task.userId = taskDTO.userId
        task.createdAt = Date.now
        
        CoreDataStack.shared.saveContext(for: Models.task.rawValue)
    }
    
    func updateTask(_ task: Task) {
        guard let updatedTask = fetchTask(task.id) else {
            debugPrint("Task with id: \(task.id) not found in storage")
            return
        }
        
        updatedTask.todo = task.todo
        updatedTask.todoDescription = updatedTask.todoDescription
        updatedTask.completed = task.completed
        
        CoreDataStack.shared.saveContext(for: Models.task.rawValue)
    }
    
    func deleteTask(_ taskId: Int64) {
        let c = CoreDataStack.shared.viewContext(for: Models.task.rawValue)
        guard let task = fetchTask(taskId) else {
            debugPrint("Task with id: \(taskId) not found in storage")
            return
        }
        c.delete(task)
        CoreDataStack.shared.saveContext(for: Models.task.rawValue)
    }
}
