//
//  MainUIAssemblyProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import UIKit

protocol MainUIAssemblyProtocol {
    
    var appAssembly: AppAssemblyProtocol { get }
    
    func assemblyMainVC() -> MainVC
    func assemblySearchVC() -> SearchVC
    func assemblyAllWordsVC() -> AllWordsVC
    func assemblyThemesVC() -> ThemesVC
}
