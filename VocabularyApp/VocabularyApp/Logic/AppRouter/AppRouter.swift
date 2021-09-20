//
//  AppRouter.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import UIKit

final class AppRouter: NSObject, AppRoutingProtocol {
    
    let appAssembly: AppAssemblyProtocol
    private var appWindow: UIWindow!
    private var rootNavigationController: UINavigationController!
    private var onboardRouter: OnboardRoutingProtocol?
    private var mainUIRouter: MainUIRoutingProtocol
    
    private let didSeeOnboardingKey: String = "appRouter.onboarding.didSeeOnboardingKey"

    init(with assembly: AppAssemblyProtocol) {
        self.appAssembly = assembly
        self.mainUIRouter = assembly.assemblyMainUIRouter()
    }
    
    // MARK: -
    // MARK: Public
    func showInitialUI(from window: UIWindow) {
        
        self.appWindow = window
        
        let navVC = UINavigationController()
        navVC.isNavigationBarHidden = true
        window.rootViewController = navVC
        self.rootNavigationController = navVC
        
        if UserDefaults.standard.bool(forKey: self.didSeeOnboardingKey) {
            self.mainUIRouter.showMainUIStory(from: self.rootNavigationController, animated: false)
        } else {
            let router = appAssembly.assemblyOnboardRouter()
            router.showOnboardStory(
                from: rootNavigationController,
                animated: false,
                completionBlock: {
                    router.hideOnboardStory(from: self.rootNavigationController, animated: true, completionBlock: nil)
                    self.mainUIRouter.showMainUIStory(from: self.rootNavigationController, animated: true)
                    self.onboardRouter = nil
                    UserDefaults.standard.set(true, forKey: self.didSeeOnboardingKey)
                })
            self.onboardRouter = router
        }
    }
    
    func handlePushNotification(word: String) {
        mainUIRouter.handlePushNotification(word: word)
    }
}

extension AppRouter: AppLaunchHandlerProtocol {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FBApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
}
