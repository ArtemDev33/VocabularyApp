//
//  OnboardRouter.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import Foundation
import UIKit

// MARK: -
// MARK: Class Declaration
final class OnboardRouter: BaseRouter {
    
    private let assembly: OnboardAssemblyProtocol
    private var storyCompletionBlock: VoidBlock?

    init(with assembly: OnboardAssemblyProtocol) {
        self.assembly = assembly
    }
}

// MARK: -
// MARK: OnBoardRoutingProtocol
extension OnboardRouter: OnboardRoutingProtocol {
    
    func showOnboardStory(from controller: UIViewController,
                          animated: Bool,
                          completionBlock: @escaping VoidBlock) {
        
        self.storyCompletionBlock = completionBlock
        self.showIntroVC(from: controller, animated: false)
    }
    
    func hideOnboardStory(from controller: UINavigationController,
                          animated: Bool,
                          completionBlock: VoidBlock?) { }
}

// MARK: -
// MARK: Internal
extension OnboardRouter {
    
    func completeFlow() {
        storyCompletionBlock?()
        storyCompletionBlock = nil
    }
    
    func showIntroVC(from controller: UIViewController, animated: Bool) {
        
        let introVC = self.assembly.assemblyIntroVC()
        introVC.delegate = self
        push(viewController: introVC, fromViewController: controller, animated: animated)
    }
    
    func showRemindersVC(from controller: UIViewController, animated: Bool) {
            
        let remindersVC = self.assembly.assemblyRemindersVC()
        remindersVC.delegate = self
        self.push(viewController: remindersVC, fromViewController: controller, animated: animated)
    }
    
    func showWidgetsVC(from controller: UIViewController, animated: Bool) {
        let widgetsVC = self.assembly.assemblyWidgetsVC()
        widgetsVC.delegate = self
        self.push(viewController: widgetsVC, fromViewController: controller, animated: animated)
    }
}
