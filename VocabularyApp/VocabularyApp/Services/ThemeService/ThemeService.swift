//
//  ThemeService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 19.05.2021.
//

import UIKit
import PromiseKit

// MARK: -
// MARK: Errors
extension ThemeService {
    enum Error: String, Swift.Error {
        case fileNotExists = "file doesn't exist"
        case invalidDirectory = "invalid directory"
        case writingFailed = "writing failed"
        case readingFailed = "reading failed"
        case invalidURL = "invalid url"
    }
}

// MARK: -
// MARK: Class declaration
final class ThemeService {
        
    private let fileManager: FileManager
    
    private let chosenThemeKey = "chosenTheme.key"
    private let chosenThemeImageKey = "chosenThemeImage.key"
    
    private var observers = WeakPointerArray<ThemeServiceObserver>()
    
    private(set) var chosenTheme: Theme?
    private(set) var chosenThemeImage: UIImage?
    
    private(set) var allThemes: [Theme] = []
    private var loadedThemesPromise: Promise<[Theme]>?
    private(set) var didFetchAllThemes = false
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        prepare()
    }
    
    func prepare() {
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            if let data = try? self.read(fileNamed: self.chosenThemeKey), let theme = self.decodeTheme(data) {
                self.chosenTheme = theme
            }
            
            if let image = try? self.readImage(named: self.chosenThemeImageKey) {
                self.chosenThemeImage = image
            }
            
            self.loadedThemesPromise = self.fetchAllThemes()
        }
    }
    
    func fetchAllThemes() -> Promise<[Theme]> {
        if let requiredPromise = self.loadedThemesPromise {
            didFetchAllThemes = true
            self.loadedThemesPromise = nil
            return requiredPromise
        } else {
            return Promise { seal in
                guard let themes = self.decodeThemes() else {
                    seal.reject(Error.readingFailed)
                    return
                }
                self.allThemes = themes
                seal.fulfill(themes)
            }
        }
    }
    
    func fetchAllLocalData() -> Promise<Void> {

        Promise { seal in
            if !allThemes.isEmpty {
                seal.fulfill(())
            }
            let queue = DispatchQueue.global(qos: .background)
            queue.async {
                guard let themes = self.decodeThemes() else {
                    seal.reject(Error.readingFailed)
                    return
                }
                self.allThemes = themes

                seal.fulfill_()
            }
        }
    }
    
    func didSelectNewTheme(_ theme: Theme, image: UIImage? = nil) {
        guard let requiredTheme = allThemes.first(where: { $0 == theme }) else {
            return
        }
        
        do {
            guard let data = encodeTheme(requiredTheme) else { return }
            try save(fileNamed: chosenThemeKey, data: data)
            chosenTheme = requiredTheme
        } catch {
            return
        }
        
        guard let requiredImage = image else {
            notifyAboutChanges(newTheme: requiredTheme)
            return
        }
        
        do {
            try save(fileNamed: chosenThemeImageKey, data: requiredImage.jpegData(compressionQuality: 1.0)!)
            chosenThemeImage = requiredImage
            notifyAboutChanges(newTheme: requiredTheme)
        } catch {
            return
        }
    }
    
    func notifyAboutChanges(newTheme: Theme) {
        observers.forEach { $0.themeServiceDidUpdate(with: newTheme) }
    }
}

// MARK: -
// MARK: Private
private extension ThemeService {
    
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
    
    func readImage(named: String) throws -> UIImage? {
        guard let url = url(forFileNamed: named) else {
            throw Error.invalidDirectory
        }
        guard fileManager.fileExists(atPath: url.path) else {
            throw Error.fileNotExists
        }
        
        return UIImage(contentsOfFile: url.path)
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
    
    func decodeThemes() -> [Theme]? {
        guard let url = Bundle.main.url(forResource: "ThemesJSON", withExtension: "txt"),
              let data = try? Data(contentsOf: url),
              let themes = try? JSONDecoder().decode(Theme.Collection.self, from: data) else {
            
            return nil
        }
        return themes.themes
    }
    
    func decodeTheme(_ data: Data) -> Theme? {
        guard let theme = try? JSONDecoder().decode(Theme.self, from: data) else {
            return nil
        }
        return theme
    }
    
    func encodeThemes(_ themes: [Theme]) -> Data? {
        guard let data = try? JSONEncoder().encode(themes) else {
            return nil
        }
        return data
    }
    
    func encodeTheme(_ theme: Theme) -> Data? {
        guard let data = try? JSONEncoder().encode(theme) else {
            return nil
        }
        return data
    }
    
    func url(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
}

// MARK: -
// MARK: ThemeService Subscriber
extension ThemeService: ThemeServiceSubscriber {
    func subscribeForUpdates(observer: ThemeServiceObserver) {
        observers.add(observer)
    }
    
    func unsubscribeFromUpdates(observer: ThemeServiceObserver) {
        observers.remove(observer)
    }
}
