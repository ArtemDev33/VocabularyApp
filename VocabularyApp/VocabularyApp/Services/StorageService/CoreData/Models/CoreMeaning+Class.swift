//
//  CoreMeaning+CoreDataClass.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation
import CoreData

class CoreMeaning: NSManagedObject {
    convenience init(context: NSManagedObjectContext, meaning: Meaning) {
        self.init(context: context)
        self.partOfSpeech = meaning.partOfSpeech
        self.definitions = Set(meaning.definitions.map { CoreDefinition(context: context, definition: $0) })
    }
}
