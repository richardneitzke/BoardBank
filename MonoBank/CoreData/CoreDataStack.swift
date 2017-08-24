//
//  CoreDataStack.swift
//  BoardBank
//
//  Created by Miguel Tepale on 8/15/17.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import CoreData
import Foundation
import UIKit

struct CoreDataStack {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let managedContext = appDelegate.persistentContainer.viewContext
}
