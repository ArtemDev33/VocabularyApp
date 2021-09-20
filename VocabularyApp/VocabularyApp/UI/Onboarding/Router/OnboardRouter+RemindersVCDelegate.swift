//
//  OnboardRouter+RemindersVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import Foundation

extension OnboardRouter: OnboardRemindersVCDelegate {
    
    func didTapContinueButton(controller: OnboardRemindersVC) {
        showWidgetsVC(from: controller, animated: true)
    }
}
