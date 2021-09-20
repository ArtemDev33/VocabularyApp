//
//  AppDelegate+APNS.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 14.07.2021.
//

import UIKit

extension AppDelegate {
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard userInfo["aps"] as? [String: AnyObject] != nil else {
            completionHandler(.failed)
            return
        }
        
        print("received successfully")
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register: \(error)")
    }
}
