//
//  OnboardAssembly.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation
import UIKit

// MARK: -
// MARK: Class declaration
final class OnboardAssembly {
    let appAssembly: AppAssemblyProtocol
    private var storyBoard: UIStoryboard = {
        UIStoryboard(name: "Onboard", bundle: nil)
    }()
    
    init(with appAssembly: AppAssemblyProtocol) {
        self.appAssembly = appAssembly
    }
}

// MARK: -
// MARK: OnboardAssemblyProtocol
extension OnboardAssembly: OnboardAssemblyProtocol {
    
    func assemblyIntroVC() -> OnboardIntroVC {
        let vc = storyBoard.instantiateViewController(withIdentifier: OnboardIntroVC.identifier) as! OnboardIntroVC
        vc.networkDictionaryService = appAssembly.assemblyNetworkDictionaryService()
        vc.storageService = appAssembly.assemblyStorageService()
        return vc
    }
    
    func assemblyRemindersVC() -> OnboardRemindersVC {
        let vc = storyBoard.instantiateViewController(withIdentifier: OnboardRemindersVC.identifier) as! OnboardRemindersVC
        vc.networkDictionaryService = appAssembly.assemblyNetworkDictionaryService()
        vc.storageService = appAssembly.assemblyStorageService()
        return vc
    }
    
    func assemblyWidgetsVC() -> OnboardWidgetsVC {
        let vc = storyBoard.instantiateViewController(withIdentifier: OnboardWidgetsVC.identifier) as! OnboardWidgetsVC
        vc.networkDictionaryService = appAssembly.assemblyNetworkDictionaryService()
        vc.storageService = appAssembly.assemblyStorageService()
        return vc
    }
}
