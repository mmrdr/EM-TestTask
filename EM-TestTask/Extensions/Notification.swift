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
    static let startAnimationEvent = Notification.Name("StartAnimationEvent")
    static let stopAnimationEvent = Notification.Name("StopAnimationEvent")
    static let showErrorEvent = Notification.Name("ShowErrorEvent")
    static let taskIdUpdatedEvent = Notification.Name("taskIdUpdatedEvent")
}
