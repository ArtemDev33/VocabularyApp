//
//  AuthenticationRouter.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.07.2021.
//

import UIKit
import Swift
import Navajo_Swift
import SwifterSwift

// MARK: -
// MARK: Errors
extension AuthRouter {
    
    enum Err: VCBError {
        case invalidAuthState
        case invalidEmailFormat
        case invalidPasswordFormat
        case invalidPhoneFormat
        case emptyPassword
        case emptyEmail
        case emptyPhone
        
        var message: String {
            switch self {
            case .invalidAuthState:      return "Invalid authorization state"
            case .invalidEmailFormat:    return "Invalid email format"
            case .invalidPasswordFormat: return "Invalid password format"
            case .invalidPhoneFormat:    return "Invalid phone format"
            case .emptyPassword:         return "Password field is empty"
            case .emptyEmail:            return "Email field is empty"
            case .emptyPhone:            return "Phone field is empty"
            }
        }
    }
}
// MARK: -
// MARK: Class Declaration
final class AuthRouter: BaseRouter {
    
    private let assembly: AuthAssemblyProtocol
    private var storyCompletionBlock: VoidBlock?
    
    let authService: AuthService
        
    private lazy var internalNVC: UINavigationController = {
        UINavigationController()
    }()

    init(with assembly: AuthAssemblyProtocol) {
        self.assembly = assembly
        self.authService = assembly.appAssembly.assemblyAuthService()
    }
}

// MARK: -
// MARK: AuthRoutingProtocol
extension AuthRouter: AuthRoutingProtocol {
    
    func showAuthenticationStory(from controller: UIViewController,
                                 animated: Bool,
                                 completionBlock: @escaping VoidBlock) {
        
        storyCompletionBlock = completionBlock
        let authPromptVC = assembly.assemblyAuthPromptVC()
        authPromptVC.delegate = self
        
        internalNVC.setViewControllers([authPromptVC], animated: false)
        show(initialController: internalNVC,
              transitionMethod: .push,
                          from: controller,
                      animated: animated,
                    completion: nil)
    }
    
    func hideAuthenticationStory(animated: Bool,
                                 completionBlock: VoidBlock?) {
        hide(animated: true, completion: nil)
    }
}

// MARK: -
// MARK: Internal
extension AuthRouter {
    
    func completeFlow() {
        storyCompletionBlock?()
        storyCompletionBlock = nil
    }
    
    func showAuthVC(from controller: UIViewController, state: AuthVC.State, animated: Bool) {
        
        let authVC = self.assembly.assemblyAuthVC()
        authVC.delegate = self
        authVC.state = state
        push(viewController: authVC, fromViewController: controller, animated: animated)
    }
    
    func showPhoneVerificationVC(from controller: UIViewController, phoneNumber: String, animated: Bool) {
        
        let phoneVerificationVC = self.assembly.assemblyPhoneVerificationVC()
        phoneVerificationVC.delegate = self
        phoneVerificationVC.phoneNumber = phoneNumber
        push(viewController: phoneVerificationVC, fromViewController: controller, animated: animated)
    }
    
    func showPasswordCreationVC(from controller: UIViewController, emailCreds: Credentials.EmailCreds, animated: Bool) {
        
        let passwordCreationVC = self.assembly.assemblyPasswordCreationVC()
        passwordCreationVC.delegate = self
        passwordCreationVC.emailCreds = emailCreds
        push(viewController: passwordCreationVC, fromViewController: controller, animated: animated)
    }
}

// MARK: -
// MARK: AuthVCDelegate
extension AuthRouter: AuthVCDelegate {
    
    func didTapSignUpButton(_ controller: AuthVC, credentials: Credentials) {
        handleAuth(controller: controller, credentials: credentials, state: .signUp)
    }
    
    func didTapSignInButton(_ controller: AuthVC, credentials: Credentials) {
        handleAuth(controller: controller, credentials: credentials, state: .signIn)
    }
    
    func didTapContinueButton(_ controller: AuthVC, credentials: Credentials) {
        verifySignUp(controller: controller, credentials: credentials, animated: true)
    }
    
    func didTapAppleButton(_ controller: AuthVC) {
        performSocialsAuth(from: controller, type: .apple)
    }
    
    func didTapFBButton(_ controller: AuthVC) {
        performSocialsAuth(from: controller, type: .fbook)
    }
    
    func didTapGoogleButton(_ controller: AuthVC) {
        performSocialsAuth(from: controller, type: .google)
    }
    
    func didTapBackButton(_ controller: AuthVC) {
        pop(viewController: controller, animated: true)
    }
}

// MARK: -
// MARK: PasswordCreationVCDelegate
extension AuthRouter: PasswordCreationVCDelegate {
 
    func didTapBackButton(_ controller: PasswordCreationVC) {
        pop(viewController: controller, animated: true)
    }
    
    func didCreatePassword(_ vc: PasswordCreationVC, credentials: Credentials.EmailCreds) {
        handleAuth(controller: vc, credentials: Credentials.email(credentials), state: .signUp)
    }
}

// MARK: -
// MARK: Private
private extension AuthRouter {
    
    func verifySignUp(controller: UIViewController, credentials: Credentials, animated: Bool) {
        switch credentials {
        case .email(let emailCreds):
            showPasswordCreationVC(from: controller, emailCreds: emailCreds, animated: animated)
        case .phone(let phoneNumber):
            controller.showActivityIndicator()

            authService.verifyPhoneNumber(phone: phoneNumber) { [weak self] error in
                controller.removeActivityIndicator()
                guard let requiredError = error else {
                    self?.showPhoneVerificationVC(from: controller, phoneNumber: phoneNumber, animated: true)
                    return
                }
                controller.showAlert(title: "Error", message: requiredError.uidescription)
            }
        }
    }
    
    func handleAuth(controller: UIViewController, credentials: Credentials, state: AuthVC.State) {

        var validEmail: String?
        var validPhone: String?
        var validPassword: String?

        switch credentials {
        case .email(let emailCreds):
            validEmail = emailCreds.email
            validPassword = emailCreds.password
        case .phone(let number):
            validPhone = number
        }

        if let email = validEmail,
           let password = validPassword {

            controller.showActivityIndicator()

            if state == .signUp {
                authService.signUp(email: email, password: password) { [weak self] error in
                    controller.removeActivityIndicator()
                    guard let requiredError = error else {
                        self?.completeFlow()
                        controller.dismiss(animated: true, completion: nil)
                        return
                    }
                    controller.showAlert(title: "Error", message: requiredError.uidescription)
                }
            } else {
                authService.signIn(email: email, password: password) { [weak self] error in
                    controller.removeActivityIndicator()
                    guard let requiredError = error else {
                        self?.completeFlow()
                        controller.dismiss(animated: true, completion: nil)
                        return
                    }
                    controller.showAlert(title: "Error", message: requiredError.uidescription)
                }
            }
        }

        if let phone = validPhone {

            controller.showActivityIndicator()

            authService.verifyPhoneNumber(phone: phone) { [weak self] error in
                controller.removeActivityIndicator()
                guard let requiredError = error else {
                    self?.showPhoneVerificationVC(from: controller, phoneNumber: phone, animated: true)
                    return
                }
                controller.showAlert(title: "Error", message: requiredError.uidescription)
            }
        }
    }
}
