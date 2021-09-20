//
//  AppDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 28.04.2021.
//

import UIKit
import Firebase
import CoreData
import Alamofire
import UserNotifications
import FBSDKCoreKit
import GoogleSignIn
import NVActivityIndicatorView

typealias VoidBlock = () -> Void
typealias StorageManager = StorageService & StorageServiceSubscriber
typealias FBApplicationDelegate = FBSDKCoreKit.ApplicationDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private(set) var appRouter: AppRoutingProtocol!
    private(set) var appAssembly: AppAssemblyProtocol!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let applicationAssembly = AppAssembly(with: window)
        self.appAssembly = applicationAssembly
        self.appRouter = applicationAssembly.assemblyAppRouter()
        self.startServices(launchOptions: launchOptions)
        
        self.appRouter.showInitialUI(from: window)
        window.makeKeyAndVisible()
        
        return appRouter.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey: Any] = [:]
        ) -> Bool {

        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled { return true }

        return ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        }  
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        finishServices()
    }
}

// MARK: -
// MARK: Private
private extension AppDelegate {
    
    func startServices(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        NVActivityIndicatorView.DEFAULT_COLOR = Design.Color.darkerGray
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScale
        
        FirebaseApp.configure()
        appAssembly.assemblyPushNotificationsService().registerForPushNotifications()
        appAssembly.assemblyIAPManager().startObserving()
    }
    
    func finishServices() {
        appAssembly.assemblyIAPManager().stopObserving()
    }
}
