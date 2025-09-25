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
        registerNotifications()
    }
    
    func viewLoaded() {
        view?.startLoadingAnimation()
        let tasks = interactor.loadAllTasksFromCoreData()
        view?.stopLoadingAnimation()
        if !tasks.isEmpty {
            let mappedTasks = mapFromCoreData(tasks)
            let sorted = mappedTasks.sorted { task1, task2 in
                return task1.createdAt ?? Date.now > task2.createdAt ?? Date.now
            }
            view?.showTasks(sorted)
        } else {
            view?.startLoadingAnimation()
            interactor.loadFirstPage() { [weak self] result in
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
    
    func reachedEnd() {
        interactor.loadNextPage() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let tasks = self.mapFromDTO(response.todos)
                self.view?.stopLoadingAnimation()
                self.view?.appendTasks(tasks)
            case .failure(let error):
                let mappedError = mapError(error)
                self.view?.showError(mappedError)
            }
        }
    }
    
    func createTask(_ task: Task) {
        view?.handleStartAnimation(task.id)
        interactor.createTask(task) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                view?.handleStopAnimation(task.id)
            case .failure(let error):
                let mappedError = self.mapError(error)
                self.view?.showError(mappedError)
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
        let titleItem = task.todo
        let descriptionItem = task.description
        let completedItem = task.completed
        let createdAtItem = task.createdAt
        let activityViewController = UIActivityViewController(
            activityItems: [titleItem, descriptionItem ?? "", completedItem, createdAtItem ?? Date()], applicationActivities: nil)

        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        activityViewController.isModalInPresentation = true
        view?.showShareMenu(activityViewController)
    }
    
    func deleteTaskPressed(_ task: Task) {
        interactor.deleteTask(task) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_): break
            case .failure(let error):
                if task.id < 255 {
                    let mappedError = self.mapError(error)
                    view?.handleError(task.id)
                    view?.showError(mappedError)
                } else {
                    view?.showError("Это не моя проблема, dummyjson не умеет удалять созданные пользователем таски(логично, бэк же не создает у себя новую таску")
                }
            }
        }
    }
    
    func openTrashHistory() {
        router.routeToTrashHistoryScreen()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleStartAnimation), name: .startAnimationEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStopAnimation), name: .stopAnimationEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleError), name: .showErrorEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskIdUpdated), name: .taskIdUpdatedEvent, object: nil)
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
                description: nil,
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
    
    @objc private func handleTaskIdUpdated(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let task = userInfo["task"] as? Task {
            interactor.createTaskInCoreData(task)
            view?.updateTaskId(task)
        }
    }
    
    @objc private func handleStartAnimation(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let taskId = userInfo["task"] as? Int64 {
            view?.handleStartAnimation(taskId)
        }
    }
    
    @objc private func handleStopAnimation(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let taskId = userInfo["task"] as? Int64 {
            view?.handleStopAnimation(taskId)
        }
    }
    
    @objc private func handleError(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let taskId = userInfo["task"] as? Int64,
           let error = userInfo["error"] as? Error
        {
            let mappedError = mapError(error)
            view?.showError(mappedError)
            view?.handleError(taskId)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .startAnimationEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .stopAnimationEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .showErrorEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .taskIdUpdatedEvent, object: nil)
    }
}
