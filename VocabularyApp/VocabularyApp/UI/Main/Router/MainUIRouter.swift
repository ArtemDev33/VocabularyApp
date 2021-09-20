//
//  MainUIRouter.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import UIKit

// MARK: -
// MARK: Class declaration
final class MainUIRouter: BaseRouter {

    private let assembly: MainUIAssemblyProtocol
    private let authRouter: AuthRoutingProtocol
    private let profileRouter: ProfileRoutingProtocol
    
    let authService: AuthService
    let iapManager: IAPManager
    
    private var navigationController: UINavigationController!
    private var mainVC: MainVC!
    
    init(with assembly: MainUIAssemblyProtocol) {
        self.assembly = assembly
        self.authRouter = assembly.appAssembly.assemblyAuthRouter()
        self.profileRouter = assembly.appAssembly.assemblyProfileRouter()
        self.authService = assembly.appAssembly.assemblyAuthService()
        self.iapManager = assembly.appAssembly.assemblyIAPManager()
    }
}

// MARK: -
// MARK: MainUIRoutingProtocol
extension MainUIRouter: MainUIRoutingProtocol {
    
    func showMainUIStory(from controller: UINavigationController, animated: Bool) {
        
        navigationController = controller
        
        mainVC = assembly.assemblyMainVC()
        mainVC.delegate = self
        mainVC.loadViewIfNeeded()
        
        controller.setViewControllers([mainVC], animated: animated)
    }
    
    func handlePushNotification(word: String) {
        guard let controller = navigationController.visibleViewController else { return }
        
        switch controller {
        case let searchVC as SearchVC:
            searchVC.newPushWord = word
        case is MainVC:
            mainVC.handlePushNotification(word: word)
        default:
            controller.dismiss(animated: true) { [unowned self] in
                self.mainVC.handlePushNotification(word: word)
            }
        }
    }
}

// MARK: -
// MARK: Internal
extension MainUIRouter {
    
    func showSearchVC(from controller: UIViewController, newPushWord: String? = nil, animated: Bool) {
        
        let searchVC = self.assembly.assemblySearchVC()
        searchVC.delegate = self
        searchVC.newPushWord = newPushWord
        controller.present(searchVC, animated: animated)
    }
    
    func showAllWordsVC(from controller: UIViewController, animated: Bool) {
        
        let allWordsVC = self.assembly.assemblyAllWordsVC()
        allWordsVC.delegate = self
        controller.present(allWordsVC, animated: animated)
    }
    
    func showThemesVC(from controller: UIViewController, animated: Bool) {
        
        let themesVC = self.assembly.assemblyThemesVC()
        themesVC.delegate = self
        let navController = UINavigationController(rootViewController: themesVC)
        controller.present(navController, animated: true, completion: nil)
    }
    
    func showProfileStory(from controller: UIViewController, animated: Bool) {
        if authService.token != nil {
            profileRouter.showProfileStory(
                from: controller,
                animated: animated,
                completionBlock: {
                    self.profileRouter.hideProfileStory(animated: true, completionBlock: nil)
                })
        } else {
            authRouter.showAuthenticationStory(
                from: controller,
                animated: animated,
                completionBlock: {
                    self.authRouter.hideAuthenticationStory(animated: true, completionBlock: nil)
                })
        }
    }
}
