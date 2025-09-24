//
//  TrashHistoryPresenter.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import Foundation

final class TrashHistoryPresenter: TrashHistoryPresenterProtocol  {
    weak var view: TrashHistoryViewProtocol?
    var interactor: TrashHistoryInteractorProtocol
    var router: TrashHistoryRouterProtocol
    
    init(view: TrashHistoryViewProtocol, interactor: TrashHistoryInteractorProtocol, router: TrashHistoryRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
        registerNotifications()
    }
    
    func viewLoaded() {
        let tasks = interactor.loadDeletedTasks()
        view?.showDeletedTasks(tasks)
    }
    
    func restorePressed(_ task: Task) {
        interactor.restoreTask(task)
    }
    
    func deletePressed(_ task: Task) {
        interactor.deleteTask(task)
    }
    
    func backButtonPressed() {
        router.routeBack()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrashDeletedEvent), name: .trashTaskDeletedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrashTaskCreatedEvent), name: .trashTaskCreatedEvent, object: nil)
    }
    
    @objc private func handleTrashDeletedEvent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let task = userInfo["task"] as? Task {
            view?.removeTaskFromScreen(task)
        }
    }
    
    @objc private func handleTrashTaskCreatedEvent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let task = userInfo["task"] as? Task {
            view?.handleTrashTaskCreatedEvent(task)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .trashTaskDeletedEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .trashTaskCreatedEvent, object: nil)
    }
}
