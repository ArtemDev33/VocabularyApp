//
//  ProfileRouter.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//

import UIKit

// MARK: -
// MARK: Class Declaration
final class ProfileRouter: BaseRouter {
    
    private let assembly: ProfileAssemblyProtocol
    private var storyCompletionBlock: VoidBlock?
    
    private let authService: AuthService
    
    private lazy var internalNVC: UINavigationController = {
        UINavigationController()
    }()

    init(with assembly: ProfileAssemblyProtocol) {
        self.assembly = assembly
        self.authService = assembly.appAssembly.assemblyAuthService()
    }
}

// MARK: -
// MARK: ProfileRoutingProtocol
extension ProfileRouter: ProfileRoutingProtocol {
    
    func showProfileStory(from controller: UIViewController, animated: Bool, completionBlock: @escaping VoidBlock) {
        storyCompletionBlock = completionBlock
        let profileVC = assembly.assemblyProfileVC()
        profileVC.delegate = self
        
        internalNVC.setViewControllers([profileVC], animated: false)
        show(initialController: internalNVC,
             transitionMethod: .push,
             from: controller,
             animated: animated,
             completion: nil)
    }
    
    func hideProfileStory(animated: Bool, completionBlock: VoidBlock?) {
        hide(animated: true, completion: nil)
    }
}

// MARK: -
// MARK: Internal
extension ProfileRouter {
    
    func completeFlow() {
        storyCompletionBlock?()
        storyCompletionBlock = nil
    }
}

// MARK: -
// MARK: ProfileVCDelegate
extension ProfileRouter: ProfileVCDelegate {
    
    func didTapSignOutButton(_ controller: ProfileVC) {
        authService.signOut()
        completeFlow()
    }
}
