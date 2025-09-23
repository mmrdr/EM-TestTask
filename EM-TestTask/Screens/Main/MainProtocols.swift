//
//  MainProtocols.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

protocol MainPresenterProtocol {
    func viewLoaded()
    func createNewTaskPressed()
    func taskCompletedStatusChanged(_ task: Task)
    func updateTaskPressed(_ task: Task)
    func shareTaskPressed(_ task: Task)
    func deleteTaskPressed(_ task: Task)
}

protocol MainInteractorProtocol {
    func loadAllTasksFromCoreData() -> [TaskEntity]
    func loadAllTasks(_ userId: Int64, completion: @escaping (Result<Tasks, Error>) -> Void)
    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    func updateTask(_ task: Task)
    func deleteTask(_ taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol MainViewProtocol: AnyObject {
    func showError(_ error: String)
    func showTasks(_ tasks: [Task])
    func startLoadingAnimation()
    func stopLoadingAnimation()
}

protocol MainRouterProtocol {
    
}
