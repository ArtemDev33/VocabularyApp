//
//  CoreMeaning+CoreDataProperties.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation
import CoreData

extension CoreMeaning {

    @nonobjc class func createFetchRequest() -> NSFetchRequest<CoreMeaning> {
        NSFetchRequest<CoreMeaning>(entityName: "CoreMeaning")
    }

    @NSManaged var partOfSpeech: String
    @NSManaged var definitions: Set<CoreDefinition>

}

// MARK: Generated accessors for definitions
extension CoreMeaning {

    @objc(addDefinitionsObject:)
    @NSManaged func addToDefinitions(_ value: CoreDefinition)

    @objc(removeDefinitionsObject:)
    @NSManaged func removeFromDefinitions(_ value: CoreDefinition)

    @objc(addDefinitions:)
    @NSManaged func addToDefinitions(_ values: NSSet)

    @objc(removeDefinitions:)
    @NSManaged func removeFromDefinitions(_ values: NSSet)

}

extension CoreMeaning: Identifiable {

}
