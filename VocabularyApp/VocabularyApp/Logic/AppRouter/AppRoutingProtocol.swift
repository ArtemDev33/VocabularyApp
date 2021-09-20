//
//  AppRoutingProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import UIKit

protocol AppRoutingProtocol: AppLaunchHandlerProtocol {
    
    var appAssembly: AppAssemblyProtocol { get }
    func showInitialUI(from window: UIWindow)
    func handlePushNotification(word: String)
}

// MARK: -
// MARK: Protocol
protocol AppLaunchHandlerProtocol: AnyObject {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
}
