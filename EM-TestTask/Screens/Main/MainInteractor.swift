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
    
    private let pageSize: Int = 30
    private var skip: Int = 0
    private var isLoading = false
    private var end = false
    
    init(coreData: CoreDataProtocol, networkService: NetworkServiceProtocol) {
        self.coreData = coreData
        self.networkService = networkService
        skip = coreData.getStorageCount()
    }
    
    func loadAllTasksFromCoreData() -> [TaskEntity] {
        let tasks = coreData.fetchAllTasks()
        return tasks
    }
    
    func loadFirstPage(completion: @escaping (Result<Tasks, any Error>) -> Void) {
        networkService
            .request(
                endpoint: "",
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
                        
                        let received = response.todos.count
                        self.skip += received
                        if self.skip >= response.total { self.end = true }
                        
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func loadNextPage(completion: @escaping (Result<Tasks, any Error>) -> Void) {
        if end { return }
        if isLoading { return }
        isLoading = true
        let query = [
            URLQueryItem(name: "limit", value: String(pageSize)),
            URLQueryItem(name: "skip", value: String(skip))
        ]
        networkService
            .request(
                endpoint: "",
                method: .get,
                queryItems: query,
                body: nil as EmptyBody?,
                headers: nil,
            ) { [weak self] (result: Result<Tasks, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    switch result {
                    case .success(let response):
                        for task in response.todos {
                            self.coreData.createTask(task)
                        }
                        let received = response.todos.count
                        self.skip += received
                        if self.skip >= response.total { self.end = true }
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
                        self.coreData.createTask(newTask)
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
    
    /// OptimisticUI
    /// - думаю лучше, чтобы пользователь в приложении видел невалидный статус "completed",
    /// чем при получении ошибок видел как у нее меняется статус обратно(т е не делаю отката состояния как при создании новой таски или удаления таски)
    /// - после перезахода в приложение он увидит, что статус не смог измениться,
    /// да, повозмущается, но не так сильно как во флоу с изменением состояния обратно, это вообще тяжело воспринимается
    /// хочу заметить, что данные в CoreData остаются синхронизированны с сервером
    
    func updateTask(_ task: Task) {
        coreData.updateTask(task)
        let request = TaskChangeRequest(completed: task.completed)
        networkService
            .request(
                endpoint: "/\(task.id)",
                method: .put,
                queryItems: nil,
                body: request as TaskChangeRequest,
                headers: nil
            ) { [weak self] (result: Result<TaskDTO, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(_): break
                    case .failure(_):
                        let newTask = Task(
                            id: task.id,
                            todo: task.todo,
                            description: task.description,
                            completed: !task.completed,
                            userId: task.userId,
                            createdAt: task.createdAt
                        )
                        self.coreData.updateTask(newTask)
                    }
                }
            }
    }
    
    /// OptimisticUI
    /// - тут то же самое, если удалит - то с экрана пропадет, даже попадет в список удаленных,
    /// но если ошибка на сервере - при получении ивента появится на главном экране и пропадет с экрана удаленных
    
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
                        self.coreData.createTask(task)
                        NotificationCenter.default.post(name: .tasksCreatedEvent, object: nil, userInfo: ["task": task])
                        self.coreData.deleteTrashTask(task.id)
                        NotificationCenter.default.post(name: .trashTaskDeletedEvent, object: nil, userInfo: ["task": task])
                        completion(.failure(error))
                    }
                }
            }
    }
}
