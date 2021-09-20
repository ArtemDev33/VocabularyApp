//
//  NotificationService.swift
//  VocabularyAppPushNotificationService
//
//  Created by Havrylenko Artem on 15.07.2021.
//

import UIKit
import PromiseKit
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    let networkImageService = NetworkImageService.shared

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let word = bestAttemptContent.userInfo["word"] as? String,
               let isNewWord = bestAttemptContent.userInfo["is_new_word"] as? Bool,
               isNewWord {
                bestAttemptContent.title = "New word: \(word)!"
            }
            
            guard let imageURLString = bestAttemptContent.userInfo["podcast-image"] as? String else {
                contentHandler(bestAttemptContent)
                return
            }

            getMediaAttachment(for: imageURLString) { [weak self] image in
                guard let self = self,
                      let image = image,
                      let fileURL = self.saveImageAttachment(image: image,
                                                             forIdentifier: "attachment.png") else {
                    contentHandler(bestAttemptContent)
                    return
              }
              let imageAttachment = try? UNNotificationAttachment(identifier: "image",
                                                                  url: fileURL,
                                                                  options: nil)
              if let imageAttachment = imageAttachment {
                  bestAttemptContent.attachments = [imageAttachment]
              }

              contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

// MARK: -
// MARK: Private
private extension NotificationService {
    
    func saveImageAttachment(image: UIImage,
                             forIdentifier: String) -> URL? {

        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let directoryPath = tempDirectory.appendingPathComponent(
            ProcessInfo.processInfo.globallyUniqueString,
            isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(
                at: directoryPath,
                withIntermediateDirectories: true,
                attributes: nil)
            
            let fileURL = directoryPath.appendingPathComponent(forIdentifier)

            guard let imageData = image.pngData() else { return nil }

            try imageData.write(to: fileURL)
            
            return fileURL
        } catch {
            return nil
        }
    }
    
    private func getMediaAttachment(for urlString: String,
                                    completion: @escaping (UIImage?) -> Void) {

        firstly {
            networkImageService.image(forURL: urlString)
        }.done(on: DispatchQueue.main) { image in
            completion(image)
        }.catch { _ in
            completion(nil)
        }
    }
}
