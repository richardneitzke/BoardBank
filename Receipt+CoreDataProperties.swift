//
//  Receipt+CoreDataProperties.swift
//  BoardBank
//
//  Created by Miguel Tepale on 8/16/17.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import Foundation
import CoreData


extension Receipt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Receipt> {
        return NSFetchRequest<Receipt>(entityName: "Receipt")
    }

    @NSManaged public var amount: Int16
    @NSManaged public var payee: String?
    @NSManaged public var payeeIndex: Int16
    @NSManaged public var payer: String?
    @NSManaged public var payerIndex: Int16

}
