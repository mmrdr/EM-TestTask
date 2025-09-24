//
//  TrashHistoryInteractor.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import Foundation

final class TrashHistoryInteractor: TrashHistoryInteractorProtocol {
    var coreData: CoreDataProtocol
    var networkService: NetworkServiceProtocol
    
    init(coreData: CoreDataProtocol, networkService: NetworkServiceProtocol) {
        self.coreData = coreData
        self.networkService = networkService
    }
    
    func restoreTask(_ task: Task, completion: @escaping (Result<TaskDTO, any Error>) -> Void) {
        //
    }
    
    func deleteTask(_ task: Task) {
        //
    }
    
}
