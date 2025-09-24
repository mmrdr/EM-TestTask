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
        view?.showDeletedTasks([])
    }
    
    func restorePressed(_ task: Task) {
        //
    }
    
    func deletePressed(_ task: Task) {
        //
    }
    
    func backButtonPressed() {
        router.routeBack()
    }
}
