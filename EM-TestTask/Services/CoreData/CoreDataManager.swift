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
        case trash = "DeletedTaskModel"
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
    
    /// надо вообще удалить эту хрень
    func createTask(_ task: TaskDTO) {
        let c = CoreDataStack.shared.viewContext(for: Models.task.rawValue)
        let newTask = TaskEntity(context: c)
        
        newTask.id = task.id
        newTask.todo = task.todo
        newTask.todoDescription = nil
        newTask.completed = task.completed
        newTask.userId = task.userId
        newTask.createdAt = Date.now
        
        CoreDataStack.shared.saveContext(for: Models.task.rawValue)
    }
    
    func createTask(_ task: Task) {
        let c = CoreDataStack.shared.viewContext(for: Models.task.rawValue)
        let newTask = TaskEntity(context: c)
        
        newTask.id = task.id
        newTask.todo = task.todo
        newTask.todoDescription = task.description
        newTask.completed = task.completed
        newTask.userId = task.userId
        newTask.createdAt = Date.now
        
        CoreDataStack.shared.saveContext(for: Models.task.rawValue)
    }
    
    func getNewTaskId() -> Int64 {
        let tasks = fetchAllTasks()
        var newId: Int64 = 1
        for task in tasks {
            newId = max(task.id, newId)
        }
        return newId + 1
    }
    
    func updateTask(_ task: Task) {
        guard let updatedTask = fetchTask(task.id) else {
            debugPrint("Task with id: \(task.id) not found in storage")
            return
        }
        updatedTask.id = task.id
        updatedTask.todo = task.todo
        updatedTask.todoDescription = task.description
        updatedTask.completed = task.completed
        debugPrint("updated: \(updatedTask.id)\n\(updatedTask.todo)/n\(updatedTask.todoDescription)")
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
    
    func deleteAll() {
        let c = CoreDataStack.shared.viewContext(for: Models.task.rawValue)
        let r: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let tasks = try c.fetch(r)
            for task in tasks {
                c.delete(task)
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func fetchTrashTask(_ taskId: Int64) -> DeletedTaskEntity? {
        let c = CoreDataStack.shared.viewContext(for: Models.trash.rawValue)
        let r: NSFetchRequest<DeletedTaskEntity> = DeletedTaskEntity.fetchRequest()
        r.predicate = NSPredicate(format: "id == %@", NSNumber(value: taskId))
        r.fetchLimit = 1
        return try? c.fetch(r).first
    }
    
    func createTrashTask(_ task: Task) {
        let c = CoreDataStack.shared.viewContext(for: Models.trash.rawValue)
        let newTask = DeletedTaskEntity(context: c)
        
        newTask.id = task.id
        newTask.todo = task.todo
        newTask.todoDescription = task.description
        newTask.userId = task.userId
        newTask.createdAt = Date.now
        
        CoreDataStack.shared.saveContext(for: Models.trash.rawValue)
    }
    
    func deleteTrashTask(_ taskId: Int64) {
        let c = CoreDataStack.shared.viewContext(for: Models.trash.rawValue)
        guard let task = fetchTrashTask(taskId) else {
            debugPrint("Trash task with id: \(taskId) not found in storage")
            return
        }
        c.delete(task)
        CoreDataStack.shared.saveContext(for: Models.trash.rawValue)
    }
}
