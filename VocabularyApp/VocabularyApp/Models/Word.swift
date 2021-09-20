//
//  Word.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 14.05.2021.
//

import Foundation

struct Word: Codable {
    let word: String
    let phonetics: String?
    let meanings: [Meaning]
    var isFavourite: Bool
    
    enum CodingKeys: String, CodingKey {
        case word
        case phonetics
        case meanings
        case isFavourite
    }
    
    enum PhoneticsKeys: String, CodingKey {
        case text
        case audio
    }
    
    init(word: String, partOfSpeech: String, definition: String?, example: String?) {
        self.word = word
        self.phonetics = nil
        self.isFavourite = false
        
        let definition = Definition(definition: definition, example: example)
        self.meanings = [Meaning(partOfSpeech: partOfSpeech, definitions: [definition])]
    }
    
    init(coreWord: CoreWord) {
        self.word = coreWord.word
        self.phonetics = coreWord.phonetics
        self.isFavourite = coreWord.isFavourite
        self.meanings = coreWord.meanings.map { Meaning(coreMeaning: $0) }
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.word = try container.decode(String.self, forKey: .word)
        self.meanings = try container.decode([Meaning].self, forKey: .meanings)
        self.isFavourite = try container.decodeIfPresent(Bool.self, forKey: .isFavourite) ?? false
        
        var phoneticsUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .phonetics)
        var phonetics: String?
        while !phoneticsUnkeyedContainer.isAtEnd {
            let phoneticsContainer = try phoneticsUnkeyedContainer.nestedContainer(keyedBy: PhoneticsKeys.self)
            phonetics = try phoneticsContainer.decode(String?.self, forKey: .text)
            if phonetics != nil {
                break
            }
        }
        self.phonetics = phonetics
    }
     
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encode(meanings, forKey: .meanings)
        try container.encode(isFavourite, forKey: .isFavourite)
        
        var phoneticsUnkeyedContainer = container.nestedUnkeyedContainer(forKey: .phonetics)
        var phoneticsContainer = phoneticsUnkeyedContainer.nestedContainer(keyedBy: PhoneticsKeys.self)
        try phoneticsContainer.encode(phonetics, forKey: .text)
    }
}

extension Word: Equatable {
    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.word == rhs.word
    }
}
