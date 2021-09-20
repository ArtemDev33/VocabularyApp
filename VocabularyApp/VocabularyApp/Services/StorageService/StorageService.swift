//
//  StorageServiceProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 13.05.2021.
//

import Foundation

protocol StorageService {
    var words: [Word] { get }
    
    func refreshStorage()
    func addWord(_ word: Word) throws
    func removeWord(_ word: Word) throws
    func toggleWordFavouriteStatus(of word: String) throws
    func contains(word: String) -> Bool
}

protocol StorageServiceSubscriber {
    func subscribeForUpdates(observer: StorageServiceObserver)
    func unsubscribeFromUpdates(observer: StorageServiceObserver)
}

protocol StorageServiceObserver: AnyObject {
    func storageServiceDidUpdate(with newWords: [Word])
    func storageServiceDidUpdate(word: Word)
    func storageServiceDidRemoveWord(_ word: Word?, at indexPath: IndexPath?)
}
