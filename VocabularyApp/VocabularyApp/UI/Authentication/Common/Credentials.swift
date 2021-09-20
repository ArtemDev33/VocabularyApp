//
//  Credentials.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//

import Foundation

enum Credentials {
    
    struct EmailCreds {
        let email: String
        var password: String?
    }
    
    case email(EmailCreds)
    case phone(String)
}
