//
//  TaskInteractor.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

final class TaskInteractor: TaskInteractorProtocol {
    
    var coreData: CoreDataProtocol
    var networkService: NetworkServiceProtocol
    let userId: Int64 = 1
    
    init(coreData: CoreDataProtocol, networkService: NetworkServiceProtocol) {
        self.coreData = coreData
        self.networkService = networkService
    }
    
    func saveTask(_ task: TaskCreateDTO) {
        let newTaskID = coreData.getNewTaskId()
        let newTask = Task(
            id: newTaskID,
            todo: task.todo,
            description: task.description,
            completed: false,
            userId: userId,
            createdAt: Date.now + 7
        )
        coreData.createTask(newTask)
        NotificationCenter.default.post(name: .tasksCreatedEvent, object: nil, userInfo: ["task": newTask])
    }
    
    // DummyJson не предоставляет возможность обновления Title у Todo, и тем более Description
    
    func updateTask(_ task: Task) {
        coreData.updateTask(task)
        NotificationCenter.default.post(name: .taskUpdatedEvent, object: nil, userInfo: ["task": task])
    }
}
