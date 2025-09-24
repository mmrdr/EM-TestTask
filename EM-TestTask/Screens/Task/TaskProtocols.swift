//
//  TaskProtocols.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

protocol TaskPresenterProtocol {
    func viewLoaded()
    func saveButtonPressed(_ taskFromScreen: TaskCreateDTO)
    func backButtonPressed()
}

protocol TaskInteractorProtocol {
    func saveTask(_ task: TaskCreateDTO)
    func updateTask(_ task: Task)
}

protocol TaskRouterProtocol {
    func routeBack()
}
