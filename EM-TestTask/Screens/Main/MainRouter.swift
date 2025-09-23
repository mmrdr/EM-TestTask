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
}
