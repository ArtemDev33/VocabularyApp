//
//  OnboardAssemblyProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation

protocol OnboardAssemblyProtocol {

    var appAssembly: AppAssemblyProtocol { get }

    func assemblyIntroVC() -> OnboardIntroVC
    func assemblyRemindersVC() -> OnboardRemindersVC
    func assemblyWidgetsVC() -> OnboardWidgetsVC
}
