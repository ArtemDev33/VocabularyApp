//
//  OnboardRouter+IntroVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import Foundation

extension OnboardRouter: OnboardIntroVCDelegate {
    
    func didTapStartButton(controller: OnboardIntroVC) {
        showRemindersVC(from: controller, animated: true)
    }
}
