//
//  TrashHistoryProtocols.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import Foundation

protocol TrashHistoryPresenterProtocol {
    func viewLoaded()
    func restorePressed(_ task: Task)
    func deletePressed(_ task: Task)
    func backButtonPressed()
}

protocol TrashHistoryInteractorProtocol {
    func restoreTask(_ task: Task, completion: @escaping (Result<TaskDTO, Error>) -> Void)
    func deleteTask(_ task: Task)
}

protocol TrashHistoryViewProtocol: AnyObject {
    func showDeletedTasks(_ tasks: [Task])
}

protocol TrashHistoryRouterProtocol {
    func routeBack()
}
