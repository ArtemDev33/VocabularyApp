//
//  AuthenticationAssembly.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.07.2021.
//

import Foundation
import UIKit

// MARK: -
// MARK: Class declaration
final class AuthAssembly {
    let appAssembly: AppAssemblyProtocol
    private var storyBoard: UIStoryboard = {
        UIStoryboard(name: "Authentication", bundle: nil)
    }()
    
    init(with appAssembly: AppAssemblyProtocol) {
        self.appAssembly = appAssembly
    }
}

// MARK: -
// MARK: AuthnAssemblyProtocol
extension AuthAssembly: AuthAssemblyProtocol {
    
    func assemblyAuthPromptVC() -> AuthPromptVC {
        storyBoard.instantiateViewController(withIdentifier: AuthPromptVC.identifier) as! AuthPromptVC
    }
    
    func assemblyAuthVC() -> AuthVC {
        storyBoard.instantiateViewController(withIdentifier: AuthVC.identifier) as! AuthVC
    }
    
    func assemblyPhoneVerificationVC() -> PhoneVerificationVC {
        storyBoard.instantiateViewController(withIdentifier: PhoneVerificationVC.identifier) as! PhoneVerificationVC
    }
    
    func assemblyPasswordCreationVC() -> PasswordCreationVC {
        storyBoard.instantiateViewController(withIdentifier: PasswordCreationVC.identifier) as! PasswordCreationVC
    }
}
