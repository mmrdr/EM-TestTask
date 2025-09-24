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
}
