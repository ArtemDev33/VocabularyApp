//
//  Meaning.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation

struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]
    
    init(partOfSpeech: String, definitions: [Definition]) {
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
    }
    
    init(coreMeaning: CoreMeaning) {
        self.partOfSpeech = coreMeaning.partOfSpeech
        self.definitions = coreMeaning.definitions.map { Definition(coreDefinition: $0) }
    }
}
