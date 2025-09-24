//
//  MainInteractor.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

final class MainInteractor: MainInteractorProtocol {
    var coreData: CoreDataProtocol
    var networkService: NetworkServiceProtocol
    
    init(coreData: CoreDataProtocol, networkService: NetworkServiceProtocol) {
        self.coreData = coreData
        self.networkService = networkService
    }
    
    func loadAllTasksFromCoreData() -> [TaskEntity] {
        let tasks = coreData.fetchAllTasks()
        return tasks
    }
    
    func loadAllTasks(_ userId: Int64, completion: @escaping (Result<Tasks, any Error>) -> Void) {
        networkService
            .request(
                endpoint: Endpoints.getByUser.rawValue + "/\(userId)",
                method: .get,
                queryItems: nil,
                body: nil as EmptyBody?,
                headers: nil,
            ) { [weak self] (result: Result<Tasks, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        for task in response.todos {
                            self.coreData.createTask(task)
                        }
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func createTask(_ task: Task, completion: @escaping (Result<TaskDTO, any Error>) -> Void) {
        let taskCreateRequest = TaskCreateRequest(todo: task.todo, completed: false, userId: 1)
        networkService
            .request(
                endpoint: Endpoints.add.rawValue,
                method: .post,
                queryItems: nil,
                body: taskCreateRequest as TaskCreateRequest,
                headers: nil
            ) { [weak self] (result: Result<TaskDTO, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        let newTask = Task(
                            id: response.id,
                            todo: response.todo,
                            description: task.description,
                            completed: response.completed,
                            userId: response.userId,
                            createdAt: task.createdAt
                        )
                        self.coreData.updateTask(newTask)
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func createTaskInCoreData(_ task: Task) {
        coreData.createTask(task)
    }
    
    func updateTask(_ task: Task) {
        coreData.updateTask(task)
    }
    
    func deleteTask(_ task: Task, completion: @escaping (Result<Void, any Error>) -> Void) {
        coreData.deleteTask(task.id)
        coreData.createTrashTask(task)
        networkService
            .request(
                endpoint: "/\(task.id)",
                method: .delete,
                queryItems: nil,
                body: nil as EmptyBody?,
                headers: nil
            ) { [weak self] (result: Result<DeletedTask, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
}
