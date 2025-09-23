//
//  MainProtocols.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

protocol MainPresenterProtocol {
    
}

protocol MainInteractorProtocol {
    func loadAllTasksFromCoreData() -> [TaskEntity]
    func loadAllTasks(_ userId: Int64, completion: @escaping (Result<Tasks, Error>) -> Void)
    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    func deleteTask(_ taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol MainViewProtocol: AnyObject {
    
}

protocol MainRouterProtocol {
    
}
