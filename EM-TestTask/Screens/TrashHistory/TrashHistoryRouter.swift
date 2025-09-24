//
//  TrashHistoryPouter.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import UIKit

final class TrashHistoryRouter: TrashHistoryRouterProtocol {
    weak var view: TrashHistoryViewController?
    
    init(view: TrashHistoryViewController) {
        self.view = view
    }

    func routeBack() {
        view?.navigationController?.popViewController(animated: true)
    }
}
