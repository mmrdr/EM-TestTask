//
//  MainProtocols.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

protocol MainPresenterProtocol {
    func viewLoaded()
    func createNewTaskPressed()
    func taskCompletedStatusChanged(_ task: Task)
    func createTask(_ task: Task)
    func updateTaskPressed(_ task: Task)
    func shareTaskPressed(_ task: Task)
    func deleteTaskPressed(_ task: Task)
    func openTrashHistory()
    
    // пагинация
    func reachedEnd()    
}

protocol MainInteractorProtocol {
    func loadAllTasksFromCoreData() -> [TaskEntity]
    func createTask(_ task: Task, completion: @escaping (Result<TaskDTO, Error>) -> Void)
    func updateTask(_ task: Task)
    func deleteTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    
    func createTaskInCoreData(_ task: Task)
    
    // пагинация
    func loadFirstPage(completion: @escaping (Result<Tasks, any Error>) -> Void)
    func loadNextPage(completion: @escaping (Result<Tasks, any Error>) -> Void)
}


protocol MainViewProtocol: AnyObject {
    func showError(_ error: String)
    func showTasks(_ tasks: [Task])
    func showShareMenu(_ activityViewController: UIActivityViewController)
    func startLoadingAnimation()
    func stopLoadingAnimation()
    func handleStartAnimation(_ taskId: Int64)
    func handleStopAnimation(_ taskId: Int64)
    func handleError(_ taskId: Int64)
    func updateTaskId(_ task: Task)
    
    // пагинация
    func appendTasks(_ newTasks: [Task])
}

protocol MainRouterProtocol {
    func routeToTaskScreen(_ task: Task?)
    func routeToTrashHistoryScreen()
}
