//
//  LossyCodableList.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 21.05.2021.
//

import Foundation

@propertyWrapper
struct LossyCodableList<Element> {
    var elements: [Element]
    
    var wrappedValue: [Element] {
        get { elements }
        set { elements = newValue }
    }
}

extension LossyCodableList: Decodable where Element: Decodable {
    private struct ElementWrapper: Decodable {
        var element: Element?

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            element = try? container.decode(Element.self)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let wrappers = try container.decode([ElementWrapper].self)
        elements = wrappers.compactMap(\.element)
    }
}

extension LossyCodableList: Encodable where Element: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for element in elements {
            try? container.encode(element)
        }
    }
}
