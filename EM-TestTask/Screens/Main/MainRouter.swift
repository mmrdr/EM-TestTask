//
//  MainRouter.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

final class MainRouter: MainRouterProtocol {
    weak var view: MainViewController?
    
    init(view: MainViewController) {
        self.view = view
    }
    
    func routeToTaskScreen(_ task: Task?) {
        view?.navigationController?.pushViewController(TaskAssembly.build(task), animated: true)
    }
    
    func routeToTrashHistoryScreen() {
        view?.navigationController?.pushViewController(TrashHistoryAssembly.build(), animated: true)
    }
}
