//
//  String+Email.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 03.08.2021.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailPred = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }

    func isValidPhone() -> Bool {
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"

        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: self)
    }
        
    func isValidPassword() -> (Bool, [String]?) {
        
        let passwordPatterns: [(regEx: String, error: String)] = [
            (regEx: "^(?=.{8,}).*", error: "At least 8 characters required"),
            (regEx: "^(?=[^A-Z]*[A-Z]).*", error: "At least 1 capital letter required"),
            (regEx: "^(?=[^a-z]*[a-z]).*", error: "At least 1 lowercase letter required"),
            (regEx: "^(?=.*[0-9]).*", error: "At least 1 digit required"),
            (regEx: "^(?=.*[ !$%&?._-]).*", error: "At least 1 special character (!$%&?._-) required")
        ]
        
        var errors: [String] = []
        passwordPatterns.forEach {
            let passwordCheck = NSPredicate(format: "SELF MATCHES %@", $0.regEx)
            if !passwordCheck.evaluate(with: self) {
                errors.append($0.error)
            }
        }
        
        if errors.isEmpty {
            return (true, nil)
        } else {
            return (false, errors)
        }
    }
}
