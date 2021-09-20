//
//  CoreDataStorageService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 13.05.2021.
//

import UIKit
import CoreData

// MARK: -
// MARK: Errors
extension CoreDataStorage {
    enum Error: String, Swift.Error {
        case entityNotExists = "entity doesn't exist"
        case savingFailed = "saving failed"
    }
}

// MARK: -
// MARK: Class
final class CoreDataStorage: StorageService {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let groupName = "group.com.nixsolutions.VocabularyAppPush.AppGroup"
        let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: groupName)!
            .appendingPathComponent("VocabularyApp.sqlite")
        
        let container = NSPersistentContainer(name: "VocabularyApp")
        
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: url)
        ]
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private(set) var words: [Word] = []
    
    private var observers = WeakPointerArray<StorageServiceObserver>()

    static let shared = CoreDataStorage()
    
    private init() {
        refreshStorage()
    }
    
    func refreshStorage() {
        do {
            words = try fetchAllWords()
        } catch {
            debugPrint(error)
        }
    }
    
    func addWord(_ word: Word) throws {
        do {
            let coreWord = createCoreWord(with: word)
            context.insert(coreWord)
            try context.save()
            words.append(word)
            notifyAboutAdding()
        } catch {
            throw Error.savingFailed
        }
    }
    
    func removeWord(_ word: Word) throws {
        guard let index = words.firstIndex(where: { $0 == word }) else {
            return
        }
        
        guard let coreWord = try? fetchCoreWord(for: word.word) else {
            throw Error.entityNotExists
        }
        
        do {
            context.delete(coreWord)
            try context.save()
            words.remove(at: index)
            notifyAboutRemoving(of: word, at: IndexPath(row: index, section: 0))
        } catch {
            throw Error.savingFailed
        }
    }
    
    func toggleWordFavouriteStatus(of word: String) throws {
        guard let index = words.firstIndex(where: { $0.word == word }) else {
            return
        }
        
        guard let coreWord = try? fetchCoreWord(for: word) else {
            throw Error.entityNotExists
        }
                
        do {
            coreWord.isFavourite = !coreWord.isFavourite
            try context.save()
            words[index].isFavourite = !words[index].isFavourite
            notifyAboutChangingFavouriteStatus(of: words[index])
        } catch {
            throw Error.savingFailed
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
private extension CoreDataStorage {
    func fetchAllWords() throws -> [Word] {
        let words = try context.fetch(CoreWord.createFetchRequest()).map { Word(coreWord: $0) }
        return words
    }
    
    func fetchCoreWord(for word: String) throws -> CoreWord? {
        do {
            let fetchRequest = CoreWord.createFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word == %@", word)
            let results = try context.fetch(fetchRequest)
            if let coreWord = results.first {
                return coreWord
            }
            return nil
        } catch {
            throw Error.entityNotExists
        }
    }
    
    func createCoreWord(with word: Word) -> CoreWord {
        let coreWord = CoreWord(context: context)
        coreWord.word = word.word
        coreWord.phonetics = word.phonetics
        coreWord.isFavourite = word.isFavourite
        
        coreWord.meanings = Set(word.meanings.map { CoreMeaning(context: context, meaning: $0) })
        
        return coreWord
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
extension CoreDataStorage: StorageServiceSubscriber {
    func subscribeForUpdates(observer: StorageServiceObserver) {
        observers.add(observer)
    }
    
    func unsubscribeFromUpdates(observer: StorageServiceObserver) {
        observers.remove(observer)
    }
}
