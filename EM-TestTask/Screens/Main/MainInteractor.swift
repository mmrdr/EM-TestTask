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
                endpoint: Endpoints.getByUser.rawValue + "\(userId)",
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
    
    func createTask(_ task: Task, completion: @escaping (Result<Task, any Error>) -> Void) {
        networkService
            .request(
                endpoint: Endpoints.add.rawValue,
                method: .post,
                queryItems: nil,
                body: task as Task,
                headers: nil
            ) { [weak self] (result: Result<TaskDTO, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        self.coreData.createTask(response)
                        let task = Task(
                            id: response.id,
                            todo: response.todo,
                            description: "No description provided",
                            completed: response.completed,
                            userId: response.userId,
                            createdAt: Date.now
                        )
                        completion(.success(task))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        }
    }
    
    func updateTask(_ task: Task, completion: @escaping (Result<Task, any Error>) -> Void) {
        networkService
            .request(
                endpoint: "\(task.id)",
                method: .put,
                queryItems: nil,
                body: task as Task,
                headers: nil,
            ) { [weak self] (result: Result<TaskDTO, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        let task = Task(
                            id: response.id,
                            todo: response.todo,
                            description: task.description,
                            completed: response.completed,
                            userId: response.userId,
                            createdAt: task.createdAt
                        )
                        self.coreData.updateTask(task)
                        completion(.success(task))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func deleteTask(_ taskId: Int64, completion: @escaping (Result<Void, any Error>) -> Void) {
        networkService
            .request(
                endpoint: "\(taskId)",
                method: .delete,
                queryItems: nil,
                body: nil as EmptyBody?,
                headers: nil
            ) { [weak self] (result: Result<DeletedTask, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
}
