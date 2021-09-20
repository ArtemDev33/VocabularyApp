//
//  VCBError.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//
import Foundation

// MARK: -
// MARK: Swift.Error + description
extension Swift.Error {
    
    var asAppError: VCBError? {
        self as? VCBError
    }
    
    var uidescription: String {
        (self as? VCBError)?.message ?? self.localizedDescription
    }
}

// MARK: -
// MARK: App Specific Error
protocol VCBError: Error {
    
    var message: String { get }
}

enum CommonError: VCBError {
    case unknownError
    
    var message: String {
        switch self {
        case .unknownError: return "Unknown Error"
        }
    }
}
