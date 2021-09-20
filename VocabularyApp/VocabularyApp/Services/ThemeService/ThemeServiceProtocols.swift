//
//  ThemeServiceProtocols.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.05.2021.
//

import Foundation

protocol ThemeServiceSubscriber {
    func subscribeForUpdates(observer: ThemeServiceObserver)
    func unsubscribeFromUpdates(observer: ThemeServiceObserver)
}

protocol ThemeServiceObserver: AnyObject {
    func themeServiceDidUpdate(with newTheme: Theme)
}
