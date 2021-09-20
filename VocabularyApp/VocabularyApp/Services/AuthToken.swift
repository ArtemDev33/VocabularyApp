//
//  AuthToken.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 03.08.2021.
//

import Foundation

struct AuthToken: Codable, Equatable {
    
    let value: String
    let expiration: Int
}
