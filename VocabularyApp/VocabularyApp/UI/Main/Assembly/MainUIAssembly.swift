//
//  MainUIAssembly.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import UIKit

// MARK: -
// MARK: Class declaration
final class MainUIAssembly {
    
    let appAssembly: AppAssemblyProtocol
    private var storyBoard: UIStoryboard = {
        UIStoryboard(name: "MainFlow", bundle: nil)
    }()
    
    init(with applicationAssembly: AppAssemblyProtocol) {
        self.appAssembly = applicationAssembly
    }
}

// MARK: -
// MARK: Protocol
extension MainUIAssembly: MainUIAssemblyProtocol {

    func assemblyMainVC() -> MainVC {
        
        let vc = storyBoard.instantiateViewController(withIdentifier: MainVC.id) as! MainVC
        vc.networkDictionaryService = appAssembly.assemblyNetworkDictionaryService()
        vc.storageService = appAssembly.assemblyStorageService()
        vc.themeService = appAssembly.assemblyThemeService()
        return vc
    }
    
    func assemblySearchVC() -> SearchVC {
        
        let vc = storyBoard.instantiateViewController(withIdentifier: SearchVC.id) as! SearchVC
        vc.networkDictionaryService = appAssembly.assemblyNetworkDictionaryService()
        vc.storageService = appAssembly.assemblyStorageService()
        return vc
    }
    
    func assemblyAllWordsVC() -> AllWordsVC {
        
        let vc = storyBoard.instantiateViewController(withIdentifier: AllWordsVC.id) as! AllWordsVC
        vc.networkDictionaryService = appAssembly.assemblyNetworkDictionaryService()
        vc.storageService = appAssembly.assemblyStorageService()
        return vc
    }
    
    func assemblyThemesVC() -> ThemesVC {
        let vc = ThemesVC()
        vc.themeService = appAssembly.assemblyThemeService()
        return vc
    }
}
