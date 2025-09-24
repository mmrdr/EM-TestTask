//
//  TaskPresenter.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

final class TaskPresenter: TaskPresenterProtocol {
    weak var view: TaskViewController?
    var interactor: TaskInteractorProtocol
    var router: TaskRouterProtocol
    let task: Task?
    
    init(view: TaskViewController, interactor: TaskInteractorProtocol, router: TaskRouterProtocol, task: Task?) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.task = task
    }
    
    func viewLoaded() {
        if let task = task {
            view?.showTask(task)
        }
    }
    
    func saveButtonPressed(_ taskFromScreen: TaskCreateDTO) {
        if let task = task {
            let updatedTask = Task(
                id: task.id,
                todo: taskFromScreen.todo,
                description: taskFromScreen.description,
                completed: task.completed,
                userId: task.userId,
                createdAt: task.createdAt
            )
            interactor.updateTask(updatedTask)
        } else {
            interactor.saveTask(taskFromScreen)
        }
    }
    
    func backButtonPressed() {
        router.routeBack()
    }
}
