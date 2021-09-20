//
//  AuthenticationAssemblyProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.07.2021.
//

import Foundation

protocol AuthAssemblyProtocol {

    var appAssembly: AppAssemblyProtocol { get }

    func assemblyAuthPromptVC() -> AuthPromptVC
    func assemblyAuthVC() -> AuthVC
    func assemblyPhoneVerificationVC() -> PhoneVerificationVC
    func assemblyPasswordCreationVC() -> PasswordCreationVC
}
