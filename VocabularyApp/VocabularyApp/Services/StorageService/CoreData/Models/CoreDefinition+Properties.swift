//
//  CoreDefinition+CoreDataProperties.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation
import CoreData

extension CoreDefinition {

    @nonobjc class func createFetchRequest() -> NSFetchRequest<CoreDefinition> {
        NSFetchRequest<CoreDefinition>(entityName: "CoreDefinition")
    }

    @NSManaged var definition: String?
    @NSManaged var example: String?

}

extension CoreDefinition: Identifiable {

}
