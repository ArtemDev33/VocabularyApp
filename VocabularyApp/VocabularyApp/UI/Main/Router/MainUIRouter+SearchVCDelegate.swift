//
//  MainUIRouter+SearchVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import Foundation

extension MainUIRouter: SearchVCDelegate {
    
    func didTapCancelButton(controller: SearchVC) {
        controller.dismiss(animated: true)
    }
}
