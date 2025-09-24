//
//  TaskAssembly.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

enum TaskAssembly {
    static func build(_ task: Task?) -> UIViewController {
        let view = TaskViewController()
        let coreData = CoreDataManager()
        let networkService = NetworkService()
        let interactor = TaskInteractor(coreData: coreData, networkService: networkService)
        let router = TaskRouter(view: view)
        let presenter = TaskPresenter(view: view, interactor: interactor, router: router, task: task)
        view.presenter = presenter
        return view
    }
}
