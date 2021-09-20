//
//  KeychainService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 03.08.2021.
//
import Foundation
import KeychainAccess

protocol KeychainServiceProtocol {
    
    func save(value: String, key: String) throws
    func value(for key: String) throws -> String?
    
    func save(data: Data, key: String) throws
    func data(for key: String) throws -> Data?
    
    func remove(key: String) throws
}

enum KeychainServiceResult {

    case success
    case failure(reason: String)
}

// MARK: -
// MARK: Class declaration
class KeychainService: KeychainServiceProtocol {
    
    private let secondaryLaunchKey = "KeychainService.isSecondaryAppLaunch"
    private let keychainStorage: Keychain
    
    required init(with identifier: String) {
        
        let keychain = Keychain(service: identifier).accessibility(.afterFirstUnlockThisDeviceOnly)
        self.keychainStorage = keychain
        
        self.removeAllIfNeeded()
    }
    
    func save(value: String, key: String) throws {
        try self.keychainStorage.set(value, key: key)
    }
    
    func value(for key: String) throws -> String? {
        try self.keychainStorage.get(key)
    }
    
    func save(data: Data, key: String) throws {
        try self.keychainStorage.set(data, key: key)
    }
    
    func data(for key: String) throws -> Data? {
        try self.keychainStorage.getData(key)
    }
    
    func remove(key: String) throws {
        try self.keychainStorage.remove(key)
    }
}

// MARK: -
// MARK: Private
fileprivate extension KeychainService {
    
    func removeAllIfNeeded() {
        
        // If app was reinstalled we need to remove old keychain keys
        let userDefaults = UserDefaults.standard
        let isSecondaryAppLaunch = userDefaults.bool(forKey: self.secondaryLaunchKey)
        
        guard isSecondaryAppLaunch == false else { return }
        
        do {
            try self.keychainStorage.removeAll()
        } catch {
            print("error: removeAll failed")
        }
        
        userDefaults.set(true, forKey: self.secondaryLaunchKey)
        userDefaults.synchronize()
    }
}
