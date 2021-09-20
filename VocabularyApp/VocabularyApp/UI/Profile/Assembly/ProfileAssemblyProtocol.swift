//
//  ProfileAssemblyProtocol.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//

import Foundation

protocol ProfileAssemblyProtocol {

    var appAssembly: AppAssemblyProtocol { get }

    func assemblyProfileVC() -> ProfileVC
}
