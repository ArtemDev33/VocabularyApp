//
//  AuthRouter+Socials.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//

import UIKit
import Firebase
import PromiseKit
import FBSDKLoginKit
import GoogleSignIn

extension AuthRouter {
    
    func performSocialsAuth(from controller: UIViewController, type: SocialsData.SType) {
        firstly {
            authService.signInSocial(controller: controller, type: type)
        }.done { data in
            self.authService.saveUserToken(token: data.token)
            self.completeFlow()
            controller.dismiss(animated: true)
        }.catch { error in
            print("error: \(error.uidescription)")
        }
    }
}
