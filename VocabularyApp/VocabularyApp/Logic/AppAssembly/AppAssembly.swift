//
//  AppAssembly.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation
import Alamofire
import CoreData

final class AppAssembly {
    
    private lazy var networkDictionaryService: NetworkDictionaryService = self.createNetworkDictionaryService()
    private lazy var storageService: StorageManager = self.createStorageService()
    private lazy var themeService: ThemeService = self.createThemeService()
    private lazy var pushNotificationsService: PushNotificationService = self.createPushNotificationsService()
    private lazy var authService: AuthService = self.createAuthService()
    private lazy var iapManager: IAPManager = self.createIAPManager()
    
    private lazy var requestBuilder: RequestBuilder = {
        let sessionManager = Session(configuration: .default, startRequestsImmediately: false)
        let requestBuilder = RequestBuilder(sessionManager: sessionManager)
        return requestBuilder
    }()
    
    private lazy var networkService: NetworkService = {
        let networkService = NetworkService(requestBuilder: requestBuilder)
        return networkService
    }()
    
    private lazy var appleAuthService: AppleAuthService = {
        let appleAuthService = AppleAuthService(with: window)
        return appleAuthService
    }()
    
    private let window: UIWindow
    
    init(with window: UIWindow) {
        self.window = window
    }
}

// MARK: -
// MARK: AppAssemblyProtocol
extension AppAssembly: AppAssemblyProtocol {
    
    func assemblyNetworkDictionaryService() -> NetworkDictionaryService { networkDictionaryService }
    func assemblyStorageService() -> StorageManager { storageService }
    func assemblyThemeService() -> ThemeService { themeService }
    func assemblyPushNotificationsService() -> PushNotificationService { pushNotificationsService }
    func assemblyAuthService() -> AuthService { authService }
    func assemblyIAPManager() -> IAPManager { iapManager }
    
    // Routing
    func assemblyAppRouter() -> AppRoutingProtocol {
        AppRouter(with: self)
    }
    
    func assemblyOnboardRouter() -> OnboardRoutingProtocol {
        
        let assembly = OnboardAssembly(with: self)
        let router = OnboardRouter(with: assembly)
        return router
    }
    
    func assemblyMainUIRouter() -> MainUIRoutingProtocol {
        
        let assembly = MainUIAssembly(with: self)
        let router = MainUIRouter(with: assembly)
        return router
    }
    
    func assemblyAuthRouter() -> AuthRoutingProtocol {
        let assembly = AuthAssembly(with: self)
        let router = AuthRouter(with: assembly)
        return router
    }
    
    func assemblyProfileRouter() -> ProfileRoutingProtocol {
        let assembly = ProfileAssembly(with: self)
        let router = ProfileRouter(with: assembly)
        return router
    }
}

// MARK: -
// MARK: Private ( Methods )
private extension AppAssembly {
    func createNetworkDictionaryService() -> NetworkDictionaryService {
        NetworkDictionaryService(networkService: networkService, requestBuilder: requestBuilder)
    }

    func createStorageService() -> StorageManager {
        CoreDataStorage.shared
    }
    
    func createThemeService() -> ThemeService {
        ThemeService()
    }
    
    func createPushNotificationsService() -> PushNotificationService {
        PushNotificationService()
    }
    
    func createAuthService() -> AuthService {
        AuthService(appleAuthService: appleAuthService)
    }
    
    func createIAPManager() -> IAPManager {
        IAPManager()
    }
}
