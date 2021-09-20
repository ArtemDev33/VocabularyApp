//
//  StorageService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 06.05.2021.
//

import Foundation

// MARK: -
// MARK: Errors
extension DiskStorage {
    enum Error: String, Swift.Error {
        case fileNotExists = "file doesn't exist"
        case invalidDirectory = "invalid directory"
        case writingFailed = "writing failed"
        case readingFailed = "reading failed"
    }
}

// MARK: -
// MARK: Class
final class DiskStorage: StorageService {
    private let key = "wordsArray.json"
    
    private let fileManager: FileManager
    private(set) var words: [Word] = []
    private var previousWordCount: Int = 0
    private var observers = WeakPointerArray<StorageServiceObserver>()
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        refreshStorage()
    }
    
    func refreshStorage() {
        guard let data = try? read(fileNamed: key),
              let words = decodeWords(data) else { return }
        self.words = words
        self.previousWordCount = words.count
    }
    
    func addWord(_ word: Word) throws {
        let oldWords = words
        words.append(word)
        
        do {
            try updateWords(words)
        } catch let error as DiskStorage.Error {
            words = oldWords
            throw error
        }
    }
    
    func removeWord(_ word: Word) throws {
        guard let index = words.firstIndex(where: { $0.word == word.word }) else {
            return
        }
        
        let oldWords = words
        words.remove(at: index)
        do {
            try updateWords(words, removed: word, at: IndexPath(row: index, section: 0))
        } catch let error as DiskStorage.Error {
            words = oldWords
            throw error
        }
    }
    
    func toggleWordFavouriteStatus(of word: String) throws {
        guard let index = words.firstIndex(where: { $0.word == word }) else {
            return
        }
        
        let previousStatus = words[index].isFavourite
        words[index].isFavourite = !words[index].isFavourite
        do {
            try updateFavouriteStatus(of: words[index])
        } catch let error as DiskStorage.Error {
            words[index].isFavourite = previousStatus
            throw error
        }
    }
    
    func contains(word: String) -> Bool {
        for item in words where item.word == word {
            return true
        }
        return false
    }
}

// MARK: -
// MARK: Private
private extension DiskStorage {
    func updateWords(_ words: [Word], removed word: Word? = nil, at indexPath: IndexPath? = nil) throws {
        guard let data = encodeWords(words) else {
            throw Error.writingFailed
        }
        
        do {
            try save(fileNamed: key, data: data)
            previousWordCount > words.count ? notifyAboutRemoving(of: word, at: indexPath) : notifyAboutAdding()
            previousWordCount = words.count
        } catch let error as DiskStorage.Error {
            throw error
        }
    }
    
    func updateFavouriteStatus(of word: Word) throws {
        guard let data = encodeWords(words) else {
            throw Error.writingFailed
        }
        
        do {
            try save(fileNamed: key, data: data)
            notifyAboutChangingFavouriteStatus(of: word)
        } catch let error as DiskStorage.Error {
            throw error
        }
    }
    
    func decodeWords(_ data: Data) -> [Word]? {
        guard let words = try? JSONDecoder().decode([Word].self, from: data) else {
            return nil
        }
        return words
    }
    
    func encodeWords(_ words: [Word]) -> Data? {
        guard let data = try? JSONEncoder().encode(words) else {
            return nil
        }
        return data
    }
    
    func save(fileNamed: String, data: Data) throws {
        guard let url = url(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw Error.writingFailed
        }
    }
    
    func read(fileNamed: String) throws -> Data {
        guard let url = url(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        guard fileManager.fileExists(atPath: url.path) else {
            throw Error.fileNotExists
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            throw Error.readingFailed
        }
    }
    
    func url(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func notifyAboutAdding() {
        observers.forEach { $0.storageServiceDidUpdate(with: self.words) }
    }
    
    func notifyAboutChangingFavouriteStatus(of word: Word) {
        observers.forEach { $0.storageServiceDidUpdate(word: word) }
    }
    
    func notifyAboutRemoving(of word: Word?, at indexPath: IndexPath?) {
        observers.forEach { $0.storageServiceDidRemoveWord(word, at: indexPath) }
    }
}

// MARK: -
// MARK: StorageService Subscriber
extension DiskStorage: StorageServiceSubscriber {
    func subscribeForUpdates(observer: StorageServiceObserver) {
        observers.add(observer)
    }
    
    func unsubscribeFromUpdates(observer: StorageServiceObserver) {
        observers.remove(observer)
    }
}
