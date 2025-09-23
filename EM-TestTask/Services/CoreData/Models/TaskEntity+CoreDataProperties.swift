//
//  TaskEntity+CoreDataProperties.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var todo: String?
    @NSManaged public var todoDescription: String?
    @NSManaged public var userId: Int64
    @NSManaged public var createdAt: Date?
    @NSManaged public var completed: Bool

}

extension TaskEntity : Identifiable {

}
