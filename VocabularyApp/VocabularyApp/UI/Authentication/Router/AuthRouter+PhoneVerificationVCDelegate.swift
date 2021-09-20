//
//  AuthRouter+PhoneVerificationVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 06.08.2021.
//

import Foundation

extension AuthRouter: PhoneVerificationVCDelegate {
    
    func didTapBackButton(_ controller: PhoneVerificationVC) {
        pop(viewController: controller, animated: true)
    }
    
    func didEnterLastDigit(_ controller: PhoneVerificationVC, code: String) {
        controller.startAnimating()
        authService.signIn(verificationCode: code) { error in
            controller.stopAnimating()
            guard let requiredError = error else {
                self.completeFlow()
                controller.dismiss(animated: true, completion: nil)
                return
            }
            controller.showAlert(title: "Error", message: requiredError.uidescription)
        }
    }
    
    func didTapResendOtp(_ controller: PhoneVerificationVC, phoneNumber: String) {
        controller.startAnimating()
        authService.verifyPhoneNumber(phone: phoneNumber) { error in
            controller.stopAnimating()
            if let requiredError = error {
                controller.showAlert(title: "Error", message: requiredError.uidescription)
            }
        }
    }
}
