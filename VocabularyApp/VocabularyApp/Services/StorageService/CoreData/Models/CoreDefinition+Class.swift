//
//  CoreDefinition+CoreDataClass.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation
import CoreData

class CoreDefinition: NSManagedObject {
    convenience init(context: NSManagedObjectContext, definition: Definition) {
        self.init(context: context)
        self.definition = definition.definition
        self.example = definition.example
    }
}
