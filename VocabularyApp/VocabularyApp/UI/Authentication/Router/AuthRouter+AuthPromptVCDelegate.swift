//
//  AuthRouter+AuthPromptVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.07.2021.
//

import Foundation

extension AuthRouter: AuthPromptVCDelegate {
    
    func didTapSignUpButton(controller: AuthPromptVC) {
        showAuthVC(from: controller, state: .signUp, animated: true)
    }
    
    func didTapSignInButton(controller: AuthPromptVC) {
        showAuthVC(from: controller, state: .signIn, animated: true)
    }
    
    func didTapBackButton(controller: AuthPromptVC) {
        completeFlow()
    }
}
