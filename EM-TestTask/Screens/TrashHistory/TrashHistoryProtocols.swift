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
    func loadDeletedTasks() -> [Task]
    func restoreTask(_ task: Task)
    func deleteTask(_ task: Task)
}

protocol TrashHistoryViewProtocol: AnyObject {
    func showDeletedTasks(_ tasks: [Task])
    func removeTaskFromScreen(_ task: Task)
    func handleTrashTaskCreatedEvent(_ task: Task)
}

protocol TrashHistoryRouterProtocol {
    func routeBack()
}
