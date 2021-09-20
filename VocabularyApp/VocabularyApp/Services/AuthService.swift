//
//  AuthService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 03.08.2021.
//
import UIKit
import Firebase
import PromiseKit
import FBSDKLoginKit
import GoogleSignIn
import KeychainAccess

// MARK: -
// MARK: Class declaration
final class AuthService {
        
    typealias CompletionBlock = (Error?) -> ()
    
    private let userTokenKey   = "userTokenKey"
    private let userAppleIDKey = "userAppleIDKey"
    
    var token: String?
    
    private let appleAuthService: AppleAuthService
    private let keychain: KeychainServiceProtocol
    
    init(with keychainService: KeychainServiceProtocol = KeychainService(with: "keychainservice_id"), appleAuthService: AppleAuthService) {
        self.keychain = keychainService
        self.appleAuthService = appleAuthService
        do {
            token = try restoreToken()
        } catch {
            print("error: token retrieval failed")
        }
    }
    
    func signInSocial(controller: UIViewController, type: SocialsData.SType) -> Promise<SocialsData> {
        switch type {
        case .apple: return appleAuthService.performAppleAuthorization()
        case .fbook: return signInWithFacebook(controller: controller)
        case .google: return signInWithGoogle(controller: controller)
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping CompletionBlock) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(CommonError.unknownError)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            guard error == nil else {
                print("error: user creation failed")
                completion(error)
                return
            }
            
            self.signIn(email: email, password: password) { error in
                guard error == nil else {
                    print("error: user sign in failed")
                    completion(error)
                    return
                }
                
                completion(nil)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping CompletionBlock) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            guard error == nil, let user = authData?.user else {
                print("error: sign in failed")
                completion(error)
                return
            }
            
            user.getIDToken { (token, error) in
                guard let requiredToken = token else {
                    print("error: token retrival failed")
                    completion(error)
                    return
                }
                
                do {
                    try self.store(value: requiredToken, forKey: self.userTokenKey)
                    self.token = requiredToken
                    completion(nil)
                } catch {
                    print("error: token save failed")
                    completion(error)
                }
            }
        }
    }
    
    func verifyPhoneNumber(phone: String, completion: @escaping CompletionBlock) {
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                completion(nil)
            }
    }
    
    func signIn(verificationCode: String, completion: @escaping CompletionBlock) {
        
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            completion(CommonError.unknownError)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil, let user = authResult?.user else {
                print("error: sign in failed")
                completion(error)
                return
            }
            
            user.getIDToken { (token, error) in
                guard let requiredToken = token else {
                    print("error: token retrival failed")
                    completion(error)
                    return
                }
                
                do {
                    try self.store(value: requiredToken, forKey: self.userTokenKey)
                    self.token = requiredToken
                    completion(nil)
                } catch {
                    print("error: token save failed")
                    completion(error)
                }
            }
        }
    }
    
    func signOut() {
        guard token != nil else { return }
        do {
            try keychain.remove(key: userTokenKey)
            token = nil
            try Auth.auth().signOut()
        } catch let error {
            print("Auth sign out failed: \(error)")
        }
    }
    
    func saveUserToken(token: String) {
        do {
            try store(value: token, forKey: userTokenKey)
            self.token = token
        } catch {
            print("error: \(error.uidescription)")
        }
    }
}

// MARK: -
// MARK: Private
private extension AuthService {
    func store(value: String, forKey key: String) throws {
        try self.keychain.save(value: value, key: key)
    }
    
    func restoreToken() throws -> String? {
        try self.keychain.value(for: userTokenKey)
    }
}

// MARK: -
// MARK: Facebook / Google
private extension AuthService {
    
    func signInWithFacebook(controller: UIViewController) -> Promise<SocialsData> {
        
        Promise<SocialsData> { seal in
            
            LoginManager().logIn(permissions: ["public_profile", "email"], viewController: controller) { loginResult in
                
                guard case .success(let granted, let declined, let token) = loginResult else {
                    seal.reject(CommonError.unknownError)
                    return
                }
                                    
                guard let requiredToken = token?.tokenString else {
                    seal.reject(CommonError.unknownError)
                    return
                }
                
                print("granted: \(granted), declined: \(declined), token: \(requiredToken)")
                    
                GraphRequest(graphPath: "me",
                             parameters: ["fields": "first_name, last_name, email"]).start { (connection, result, error) in
                        
                    if let error = error {
                        seal.reject(error)
                        return
                    }
                                    
                    if let fields = result as? [String: Any],
                       let firstname = fields["first_name"] as? String,
                       let lastname = fields["last_name"] as? String {
                                        
                        let fbdata = SocialsData.FacebookData(
                            firstname: firstname,
                            lastname: lastname,
                            token: requiredToken)
                        
                        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                        
                        Auth.auth().signIn(with: credential) { _, error in
                            if let error = error {
                                seal.reject(error)
                                return
                            }
                            
                            seal.fulfill(.fbook(fbdata))
                        }
                    } else {
                        seal.reject(CommonError.unknownError)
                    }
                 
                }
            }
        }
    }
    
    func signInWithGoogle(controller: UIViewController) -> Promise<SocialsData> {
        
        Promise<SocialsData> { seal in
            let signInConfig = GIDConfiguration(clientID: "655228733683-g53ls51er9npvu2blq738pm0q10dtp18.apps.googleusercontent.com",
                                                serverClientID: "655228733683-oo6ctjp362qhhc9o6ce4q3q10db8k3eo.apps.googleusercontent.com")
            
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: controller) { user, error in
                guard error == nil else {
                    seal.reject(error!)
                    return
                }
                
                guard let name = user?.profile?.name,
                      let token = user?.authentication.idToken else {
                    seal.reject(CommonError.unknownError)
                    return
                }
                
                let googleData = SocialsData.GoogleData(name: name, token: token)
                seal.fulfill(.google(googleData))
            }
        }
    }
}
