//
//  PersistentSession+CoreDataProperties.swift
//  XY_APP
//
//  Created by Maxime Franchot on 12/12/2020.
//
//

import Foundation
import CoreData


extension PersistentSession {

    @nonobjc public class func fetchRequest2() -> NSFetchRequest<PersistentSession> {
        return NSFetchRequest<PersistentSession>(entityName: "PersistentSession")
    }

    @NSManaged public var token: String?
    @NSManaged public var username: String?

}
