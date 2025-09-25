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
        NotificationCenter.default.post(name: .tasksCreatedEvent, object: nil, userInfo: ["task": newTask])
        
        sendRequest(task, newTaskID)
    }
    
    // DummyJson не предоставляет возможность обновления Title у Todo, и тем более Description
    
    func updateTask(_ task: Task) {
        coreData.updateTask(task)
        NotificationCenter.default.post(name: .taskUpdatedEvent, object: nil, userInfo: ["task": task])
    }
    
    /// Сделал именно так, через NotificationCenter, почему?
    /// - Принцип Optimistic UI
    /// - Пользователь сразу увидет созданную таску, но она будет на этапе загрузки, как только загрузится, значек загрузки пропадет
    /// - Если произойдет ошибка, то пользователь это увидит это
    /// - Логика такая же как у отправки сообщения в телеграме
    private func sendRequest(_ taskDTO: TaskCreateDTO, _ taskId: Int64) {
        let taskCreateRequest = TaskCreateRequest(todo: taskDTO.todo, completed: false, userId: userId)
        NotificationCenter.default.post(name: .startAnimationEvent, object: nil, userInfo: ["task": taskId])
        networkService
            .request(
                endpoint: Endpoints.add.rawValue + "fafwa",
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
                            userInfo: ["task": taskId]
                        )
                    switch result {
                    case .success(let response):
                        let task = Task(
                            id: response.id,
                            todo: response.todo,
                            description: taskDTO.description,
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
                                userInfo: ["task": taskId, "error": error]
                            )
                    }
                }
            }
    }
}
