//
//  Notification.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import Foundation

extension Notification.Name {
    static let tasksCreatedEvent = Notification.Name("TasksCreatedEvent")
    static let taskUpdatedEvent = Notification.Name("TaskUpdatedEvent")
    static let trashTaskCreatedEvent = Notification.Name("TrashTaskCreatedEvent")
    static let trashTaskRestoredEvent = Notification.Name("TrashTaskRestoredEvent")
}
