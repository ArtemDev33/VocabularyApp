//
//  MainUIRouter+AllWordsVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import Foundation

extension MainUIRouter: AllWordsVCDelegate {
    
    func didTapCancelButton(controller: AllWordsVC) {
        controller.dismiss(animated: true)
    }
}
