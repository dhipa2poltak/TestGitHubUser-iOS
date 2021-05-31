//
//  History+CoreDataProperties.swift
//  TestGitHubUser
//
//  Created by user on 31/05/21.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var added: Date?
    @NSManaged public var history: String?

}

extension History : Identifiable {

}
