//
//  AuthenticationRoutingProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.07.2021.
//

import Foundation
import UIKit

protocol AuthRoutingProtocol {
    
    func showAuthenticationStory(from controller: UIViewController,
                                 animated: Bool,
                                 completionBlock: @escaping VoidBlock)
    
    func hideAuthenticationStory(animated: Bool,
                                 completionBlock: VoidBlock?)
}
