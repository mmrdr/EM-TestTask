//
//  TaskEntity.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

struct TaskCreateDTO: Codable {
    let todo: String
    let description: String?
}

struct TaskCreateRequest: Codable {
    let todo: String
    let completed: Bool
    let userId: Int64
}
