//
//  ProfileAssembly.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//

import Foundation
import UIKit

// MARK: -
// MARK: Class declaration
final class ProfileAssembly {
    let appAssembly: AppAssemblyProtocol
    private var storyBoard: UIStoryboard = {
        UIStoryboard(name: "Profile", bundle: nil)
    }()
    
    init(with appAssembly: AppAssemblyProtocol) {
        self.appAssembly = appAssembly
    }
}

// MARK: -
// MARK: ProfileAssemblyProtocol
extension ProfileAssembly: ProfileAssemblyProtocol {
    
    func assemblyProfileVC() -> ProfileVC {
        let vc = storyBoard.instantiateViewController(withIdentifier: ProfileVC.identifier) as! ProfileVC
        return vc
    }
}
