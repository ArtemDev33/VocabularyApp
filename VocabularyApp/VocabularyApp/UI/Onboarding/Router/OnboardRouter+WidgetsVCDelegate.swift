//
//  OnboardRouter+WidgetsVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import Foundation

extension OnboardRouter: OnboardWidgetsVCDelegate {
    
    func didTapGotItButton(controller: OnboardWidgetsVC) {
        completeFlow()
    }
}
