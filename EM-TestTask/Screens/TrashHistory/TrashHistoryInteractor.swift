//
//  TrashHistoryInteractor.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import Foundation

final class TrashHistoryInteractor: TrashHistoryInteractorProtocol {
    var coreData: CoreDataProtocol
    var networkService: NetworkServiceProtocol
    
    init(coreData: CoreDataProtocol, networkService: NetworkServiceProtocol) {
        self.coreData = coreData
        self.networkService = networkService
    }
    
    func loadDeletedTasks() -> [Task] {
        let tasks = mapFromCoreData(coreData.fetchAllTrashTasks())
        return tasks
    }
    
    func restoreTask(_ task: Task) {
        coreData.deleteTrashTask(task.id)
        NotificationCenter.default.post(name: .tasksCreatedEvent, object: nil, userInfo: ["task": task])
        let taskCreateRequest = TaskCreateRequest(todo: task.todo, completed: false, userId: 1)
        NotificationCenter.default.post(name: .startAnimationEvent, object: nil, userInfo: ["task": task.id])
        networkService
            .request(
                endpoint: Endpoints.add.rawValue,
                method: .post,
                queryItems: nil,
                body: taskCreateRequest as TaskCreateRequest,
                headers: nil
            ) { (result: Result<TaskDTO, Error>) in

                DispatchQueue.main.async {
                    NotificationCenter.default
                        .post(
                            name: .stopAnimationEvent,
                            object: nil,
                            userInfo: ["task": task.id]
                        )
                    switch result {
                    case .success(let response):
                        let task = Task(
                            id: response.id,
                            todo: response.todo,
                            description: task.description,
                            completed: false,
                            userId: 1,
                            createdAt: Date.now
                        )
                        NotificationCenter.default
                            .post(
                                name: .taskIdUpdatedEvent,
                                object: nil,
                                userInfo: ["task": task]
                            )
                    case .failure(let error):
                        NotificationCenter.default
                            .post(
                                name: .showErrorEvent,
                                object: nil,
                                userInfo: ["task": task.id, "error": error]
                            )
                    }
                }
            }
    }
    
    func deleteTask(_ task: Task) {
        coreData.deleteTrashTask(task.id)
    }
    
    private func mapFromCoreData(_ tasks: [DeletedTaskEntity]) -> [Task] {
        var mappedTasks: [Task] = []
        for task in tasks {
            guard let todo = task.todo else { return [] }
            let mappedTask = Task(
                id: task.id,
                todo: todo,
                description: task.todoDescription,
                completed: false,
                userId: task.userId,
                createdAt: task.createdAt ?? Date.now
            )
            mappedTasks.append(mappedTask)
        }
        return mappedTasks
    }
}
