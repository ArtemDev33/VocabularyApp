//
//  OnboardRoutingProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 18.05.2021.
//

import Foundation
import UIKit

protocol OnboardRoutingProtocol {
    
    func showOnboardStory(from controller: UIViewController,
                          animated: Bool,
                          completionBlock: @escaping VoidBlock)
    
    func hideOnboardStory(from controller: UINavigationController,
                          animated: Bool,
                          completionBlock: VoidBlock?)
}
