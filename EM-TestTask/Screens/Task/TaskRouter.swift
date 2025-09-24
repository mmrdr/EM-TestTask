//
//  TaskRouter.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

final class TaskRouter: TaskRouterProtocol {
    weak var view: TaskViewController?
    
    init(view: TaskViewController) {
        self.view = view
    }
    
    func routeBack() {
        view?.navigationController?.popViewController(animated: true)
    }
}
