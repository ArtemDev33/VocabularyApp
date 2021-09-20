//
//  Definition.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation

struct Definition: Codable {
    let definition: String?
    let example: String?
    
    init(definition: String?, example: String?) {
        self.definition = definition
        self.example = example
    }
    
    init(coreDefinition: CoreDefinition) {
        self.definition = coreDefinition.definition
        self.example = coreDefinition.example
    }
}
