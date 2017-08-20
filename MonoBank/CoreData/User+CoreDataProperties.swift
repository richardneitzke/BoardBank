//
//  User+CoreDataProperties.swift
//  BoardBank
//
//  Created by Miguel Tepale on 8/17/17.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var balance: Int
    @NSManaged public var name: String?
    @NSManaged public var token: String?
    @NSManaged public var index: Int16

}
