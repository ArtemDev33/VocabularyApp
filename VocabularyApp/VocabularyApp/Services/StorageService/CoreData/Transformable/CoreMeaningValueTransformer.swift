//
//  CoreMeaningValueTransformer.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 13.05.2021.
//

import Foundation

@objc(CoreMeaningValueTransformer)
final class CoreMeaningValueTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: CoreMeaningValueTransformer.self))
    
    override static var allowedTopLevelClasses: [AnyClass] {
        [CoreMeaning.self, NSArray.self]
    }
    
    public static func register() {
        let transformer = CoreMeaningValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
