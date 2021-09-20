//
//  SocialsData.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 06.08.2021.
//

import Foundation

enum SocialsData {
    
    enum SType {
        case apple, fbook, google
    }
    
    struct AppleData {
        let name: String
        let userID: String
        let token: String
    }
    
    struct FacebookData {
        let firstname: String
        let lastname: String
        let token: String
    }

    struct GoogleData {
        let name: String
        let token: String
    }
    
    case apple(AppleData)
    case fbook(FacebookData)
    case google(GoogleData)
    
    var token: String {
        switch self {
        case .apple(let data) : return data.token
        case .fbook(let data) : return data.token
        case .google(let data): return data.token
        }
    }
    
    var name: String {
        switch self {
        case .apple(let data) : return data.name
        case .fbook(let data) : return data.firstname + " " + data.lastname
        case .google(let data): return data.name
        }
    }
}
