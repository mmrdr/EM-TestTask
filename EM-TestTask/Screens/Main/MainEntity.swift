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
    var completed: Bool
    let userId: Int64
    let createdAt: Date?
}

struct TaskDTO: Codable, Equatable {
    let id: Int64
    let todo: String
    let completed: Bool
    let userId: Int64
}

struct Tasks: Codable {
    let todos: [TaskDTO]
    let total: Int64
    let skip: Int64
    let limit: Int64
}

struct TaskChangeRequest: Codable {
    let completed: Bool
}

struct DeletedTask: Codable {
    let id: Int64
    let todo: String
    let completed: Bool
    let userId: Int64
    let isDeleted: Bool
    let deletedOn: Date
}

struct EmptyBody: Codable {}
