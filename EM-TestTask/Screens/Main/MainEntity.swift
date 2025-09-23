//
//  MainEntity.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

struct Task: Codable {
    let id: Int64
    let todo: String
    let description: String?
    let completed: Bool
    let userId: Int64
    let createdAt: Date?
}

struct TaskDTO: Codable {
    let id: Int64
    let todo: String
    let completed: Bool
    let userId: Int64
}
