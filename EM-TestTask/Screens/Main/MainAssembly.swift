//
//  MainAssembly.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

enum MainAssembly {
    static func build() -> UIViewController {
        let view = MainViewController()
        let interactor = MainInteractor()
        let router = MainRouter(view: view)
        let presenter = MainPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
}
