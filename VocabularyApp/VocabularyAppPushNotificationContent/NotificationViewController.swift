//
//  NotificationViewController.swift
//  VocabularyAppPushNotificationContent
//
//  Created by Havrylenko Artem on 15.07.2021.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var definitionLabel: UILabel!
    @IBOutlet private weak var exampleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    
    private var receivedWord: Word?
    private let storageService = CoreDataStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction private func didTapSaveButton(_ sender: UIButton) {
        guard let word = receivedWord else { return }
        
        do {
            try storageService.addWord(word)
            saveButton.isHidden = true
            removeButton.isHidden = false
        } catch {
            print("error")
        }
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        guard let word = receivedWord else { return }

        do {
            try storageService.removeWord(word)
            saveButton.isHidden = false
            removeButton.isHidden = true
        } catch {
            print("error")
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        
        let content = notification.request.content
        
        guard let word = content.userInfo["word"] as? String,
              let partOfSpeech = content.userInfo["part_of_speech"] as? String else { return }
        
        let definition = content.userInfo["definition"] as? String
        let example = content.userInfo["example"] as? String
        
        titleLabel.text = content.title
        definitionLabel.text = definition != nil ? "(\(partOfSpeech)) \(definition!)" : "(\(partOfSpeech))"
        exampleLabel.text = example != nil ? "\"\(example!)\"" : ""
        
        if let isNewWord = content.userInfo["is_new_word"] as? Bool {
            saveButton.isHidden = !isNewWord
            removeButton.isHidden = isNewWord
        }
        
        receivedWord = Word(word: word, partOfSpeech: partOfSpeech, definition: definition, example: example)

        guard let attachment = content.attachments.first,
              attachment.url.startAccessingSecurityScopedResource() else { return }

        let fileURLString = attachment.url

        guard let imageData = try? Data(contentsOf: fileURLString), let image = UIImage(data: imageData) else {
            attachment.url.stopAccessingSecurityScopedResource()
            return
        }

        imageView.image = image
        attachment.url.stopAccessingSecurityScopedResource()
    }
}

// MARK: -
// MARK: Private
private extension NotificationViewController {
    func setupUI() {
        saveButton.layer.cornerRadius = 10
        removeButton.layer.cornerRadius = 10
    }
}
