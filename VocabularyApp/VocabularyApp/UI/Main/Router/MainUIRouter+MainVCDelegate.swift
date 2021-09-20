//
//  MainUIRouter+MainVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import Foundation
import PromiseKit

extension MainUIRouter: MainVCDelegate {
    
    func didLoadView(_ controller: MainVC) {
        firstly {
            iapManager.fetchProducts()
        }.done { products in
            controller.showAlert(title: "Success", message: products[0].localizedTitle)
        }.catch { error in
            if let iapError = error as? IAPManager.Err {
                controller.showAlert(title: "Error", message: iapError.message)
            } else {
                controller.showAlert(title: "Error", message: error.uidescription)
            }
        }
    }
    
    func didTapFindWordButton(_ controller: MainVC) {
        showSearchVC(from: controller, animated: true)
    }
    
    func didTapMenuButton(_ controller: MainVC) {
        showAllWordsVC(from: controller, animated: true)
    }
    
    func didTapThemesButton(_ controller: MainVC) {
        showThemesVC(from: controller, animated: true)
    }
    
    func didTapProfileButton(_ controller: MainVC) {
        showProfileStory(from: controller, animated: true)
    }
    
    func didReceiveNewPushWord(_ controller: MainVC, word: String) {
        showSearchVC(from: controller, newPushWord: word, animated: true)
    }
}
