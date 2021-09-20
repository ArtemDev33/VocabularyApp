//
//  MainUIRoutingProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import UIKit

protocol MainUIRoutingProtocol {

    func showMainUIStory(from controller: UINavigationController, animated: Bool)
    func handlePushNotification(word: String)
}
