//
//  PushNotificationService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 12.07.2021.
//

import UIKit
import UserNotifications

private extension PushNotificationService {
    
    enum ActionIdentifier: String {
      case show, close
    }
}

// MARK: -
// MARK: Class declaration
final class PushNotificationService: NSObject {
    
    private let categoryIdentifier = "new_word_available"

    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: options) { [weak self] (granted, _ ) in
            guard granted else { return }
            self?.registerCustomActions()
            DispatchQueue.main.async {
                self?.handleNotificationSettings()
            }
        }
    }
    
    func handleNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] (settings) in
            DispatchQueue.main.async {
               
                switch settings.authorizationStatus {
                case .denied:
                    self?.unregisterForRemoteNotifications()
                case .authorized:
                    UIApplication.shared.registerForRemoteNotifications()
                default:
                    break
                }
            }
        }
    }
}

// MARK: -
// MARK: Private
private extension PushNotificationService {
    
    func unregisterForRemoteNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    func registerCustomActions() {
        let show = UNNotificationAction(identifier: ActionIdentifier.show.rawValue,
                                        title: "Show",
                                        options: [.foreground])
        
        let close = UNNotificationAction(identifier: ActionIdentifier.close.rawValue,
                                         title: "Remind me later",
                                         options: [.destructive])
        
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: [show, close],
                                              intentIdentifiers: [])
        
        UNUserNotificationCenter.current()
            .setNotificationCategories([category])
    }
}

// MARK: -
// MARK: UNUserNotificationCenterDelegate
extension PushNotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let word = userInfo["word"] as? String else {
            completionHandler()
            return
        }
        
        if response.notification.request.content.categoryIdentifier == categoryIdentifier,
           let action = ActionIdentifier(rawValue: response.actionIdentifier),
           action == .close {
            
            completionHandler()
            return
        }
           
        appDelegate.appRouter.handlePushNotification(word: word)
        completionHandler()
    }
}
