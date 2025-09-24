//
//  DeletedTaskEntity+CoreDataProperties.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//
//

import Foundation
import CoreData


extension DeletedTaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeletedTaskEntity> {
        return NSFetchRequest<DeletedTaskEntity>(entityName: "DeletedTaskEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var userId: Int64
    @NSManaged public var todo: String?
    @NSManaged public var todoDescription: String?
    @NSManaged public var createdAt: Date?

}

extension DeletedTaskEntity : Identifiable {

}
