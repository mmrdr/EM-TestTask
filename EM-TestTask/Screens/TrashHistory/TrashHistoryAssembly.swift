//
//  TrashHistoryAssembly.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import UIKit

enum TrashHistoryAssembly {
    static func build() -> UIViewController {
        let view = TrashHistoryViewController()
        let coreData = CoreDataManager()
        let networkService = NetworkService()
        let interactor = TrashHistoryInteractor(coreData: coreData, networkService: networkService)
        let router = TrashHistoryRouter(view: view)
        let presenter = TrashHistoryPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
}
