//
//  MainPrsenter.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

final class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    var interactor: MainInteractorProtocol
    var router: MainRouterProtocol
    
    /// Решил мой пользователь фиксирован - 1
    private let userId: Int64 = 1
    
    init(view: MainViewProtocol, interactor: MainInteractorProtocol, router: MainRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewLoaded() {
        let tasks = interactor.loadAllTasksFromCoreData()
        for task in tasks {
            print("\(task.id)/n")
        }
        if !tasks.isEmpty {
            let mappedTasks = mapFromCoreData(tasks)
            let sorted = mappedTasks.sorted { task1, task2 in
                return task1.createdAt ?? Date.now > task2.createdAt ?? Date.now
            }
            view?.showTasks(sorted)
        } else {
            view?.startLoadingAnimation()
            interactor.loadAllTasks(userId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    let tasks = self.mapFromDTO(response.todos)
                    self.view?.stopLoadingAnimation()
                    self.view?.showTasks(tasks)
                case .failure(let error):
                    let mappedError = mapError(error)
                    self.view?.showError(mappedError)
                }
            }
        }
    }
    
    func taskCompletedStatusChanged(_ task: Task) {
        interactor.updateTask(task)
    }
    
    func createNewTaskPressed() {
        router.routeToTaskScreen(nil)
    }
    
    func updateTaskPressed(_ task: Task) {
        router.routeToTaskScreen(task)
    }
    
    func shareTaskPressed(_ task: Task) {
        //
    }
    
    func deleteTaskPressed(_ task: Task) {
        interactor.deleteTask(task.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_): break
            case .failure(let error):
                let mappedError = self.mapError(error)
                view?.showError(mappedError)
            }
        }
    }
    
    func openTrashHistory() {
        //
    }
    
    private func mapFromCoreData(_ tasks: [TaskEntity]) -> [Task] {
        var mappedTasks: [Task] = []
        for task in tasks {
            guard let todo = task.todo else { return [] }
            let mappedTask = Task(
                id: task.id,
                todo: todo,
                description: task.todoDescription,
                completed: task.completed,
                userId: task.userId,
                createdAt: task.createdAt ?? Date.now
            )
            mappedTasks.append(mappedTask)
        }
        return mappedTasks
    }
    
    private func mapFromDTO(_ tasks: [TaskDTO]) -> [Task] {
        var mappedTasks: [Task] = []
        for task in tasks {
            let mappedTask = Task(
                id: task.id,
                todo: task.todo,
                description: "No description provided",
                completed: task.completed,
                userId: task.userId,
                createdAt: Date.now
            )
            mappedTasks.append(mappedTask)
        }
        return mappedTasks
    }
    
    private func mapError(_ error: Error) -> String {
        debugPrint(error)
        guard let error = error as? NetworkError else { return "Something went wrong, try later please"}
        switch error {
        case .noData:
            return "Server storage error, try later"
        case .decodingError:
            break
        case .internalServerError:
            return "Server error, try later"
        case .unknown(_):
            break
        case .forbidden:
            return "Access is denied for this action, dont do this!"
        case .notFound:
            break
        case .invalidURL:
            break
        }
        return "Something went wrong"
    }
}
