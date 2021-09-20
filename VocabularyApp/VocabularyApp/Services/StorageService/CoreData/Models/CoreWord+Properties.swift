//
//  CoreWord+CoreDataProperties.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 13.05.2021.
//
//

import Foundation
import CoreData

extension CoreWord {
    
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CoreWord> {
        NSFetchRequest<CoreWord>(entityName: "CoreWord")
    }
    
    @NSManaged var word: String
    @NSManaged var phonetics: String?
    @NSManaged var meanings: Set<CoreMeaning>
    @NSManaged var isFavourite: Bool
}

// MARK: Generated accessors for definitions
extension CoreWord {

    @objc(addDefinitionsObject:)
    @NSManaged func addToMeanings(_ value: CoreMeaning)

    @objc(removeDefinitionsObject:)
    @NSManaged func removeFromMeanings(_ value: CoreMeaning)

    @objc(addDefinitions:)
    @NSManaged func addToMeanings(_ values: NSSet)

    @objc(removeDefinitions:)
    @NSManaged func removeFromMeanings(_ values: NSSet)

}

extension CoreWord: Identifiable {
    
}
