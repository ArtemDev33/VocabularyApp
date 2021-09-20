//
//  AppleAuthService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//

import Foundation
import Firebase
import PromiseKit
import CryptoKit
import AuthenticationServices

// MARK: -
// MARK: Errors
extension AppleAuthService {
    enum Err: VCBError {
        
        case token(TokenError)
        case auth(ASAuthorizationError)
        
        var message: String {
            switch self {
            case .auth(let err):  return err.uidescription
            case .token(let err): return err.message
            }
        }
    }
            
    enum TokenError: VCBError {
        case fetch
        case parse
        
        var message: String {
            switch self {
            case .fetch: return "Unable to fetch identity token"
            case .parse: return "Unable to serialize token string"
            }
        }
    }
}

// MARK: -
// MARK: Class declaration
final class AppleAuthService: NSObject {
    
    private let window: UIWindow
    private var currentNonce: String?
    
    init(with window: UIWindow) {
        self.window = window
    }
    
    private var authCompletion: Resolver<SocialsData>?
    
    func performAppleAuthorization() -> Promise<SocialsData> {
        Promise<SocialsData> { [weak self] seal in
            guard let self = self else { return }
            currentNonce = randomNonceString()
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(currentNonce!)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()

            self.authCompletion = seal
        }
    }
}

// MARK: -
// MARK: Private
private extension AppleAuthService {
    
    func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

// MARK: -
// MARK: ASAuthorizationControllerDelegate
extension AppleAuthService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
     
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.authCompletion?.reject(Err.token(.fetch))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.authCompletion?.reject(Err.token(.fetch))
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { (_, error) in
                if let requiredError = error {
                    self.authCompletion?.reject(requiredError)
                    return
                }
                
                let name = (appleIDCredential.fullName?.givenName ?? "") + (appleIDCredential.fullName?.familyName ?? "")
                let userID = appleIDCredential.user
                
                let appleData = SocialsData.AppleData(name: name, userID: userID, token: idTokenString)
                self.authCompletion?.fulfill(.apple(appleData))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        
        guard let error = error as? ASAuthorizationError else {
            return
        }

        self.authCompletion?.reject(Err.auth(error))
    }
}

// MARK: -
// MARK: ASAuthorizationControllerPresentationContextProviding
extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.window
    }
}
