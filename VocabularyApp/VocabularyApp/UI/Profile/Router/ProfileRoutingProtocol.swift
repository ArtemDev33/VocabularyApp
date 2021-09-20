//
//  ProfileRoutingProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//
import Foundation
import UIKit

protocol ProfileRoutingProtocol {
    
    func showProfileStory(from controller: UIViewController,
                          animated: Bool,
                          completionBlock: @escaping VoidBlock)
    
    func hideProfileStory(animated: Bool,
                          completionBlock: VoidBlock?)
}
