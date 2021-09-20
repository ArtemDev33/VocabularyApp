//
//  AppAssemblyProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation

protocol AppAssemblyProtocol {
        
    // Routing
    func assemblyAppRouter() -> AppRoutingProtocol
    func assemblyOnboardRouter() -> OnboardRoutingProtocol
    func assemblyMainUIRouter() -> MainUIRoutingProtocol
    func assemblyAuthRouter() -> AuthRoutingProtocol
    func assemblyProfileRouter() -> ProfileRoutingProtocol
    
    // Services
    func assemblyNetworkDictionaryService() -> NetworkDictionaryService
    func assemblyStorageService() -> StorageManager
    func assemblyThemeService() -> ThemeService
    func assemblyPushNotificationsService() -> PushNotificationService
    func assemblyAuthService() -> AuthService
    func assemblyIAPManager() -> IAPManager
}
