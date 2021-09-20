//
//  AuthVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 21.07.2021.
//

import UIKit
import SnapKit
import AuthenticationServices
import FBSDKLoginKit
import GoogleSignIn

// MARK: -
// MARK: Delegate
protocol AuthVCDelegate: AnyObject {
    func didTapBackButton(_ controller: AuthVC)
    func didTapSignUpButton(_ controller: AuthVC, credentials: Credentials)
    func didTapSignInButton(_ controller: AuthVC, credentials: Credentials)
    func didTapContinueButton(_ controller: AuthVC, credentials: Credentials)
    func didTapAppleButton(_ controller: AuthVC)
    func didTapFBButton(_ controller: AuthVC)
    func didTapGoogleButton(_ controller: AuthVC)
}

// MARK: -
// MARK: State
extension AuthVC {
    enum State {
        case signIn
        case signUp
    }
    
    enum CredsType {
        case email
        case phone
    }
}

// MARK: -
// MARK: Class declaration
final class AuthVC: UIViewController {
    
    @IBOutlet private weak var authSmallTitleLabel: UILabel!
    @IBOutlet private weak var authTitleLabel: UILabel!
    @IBOutlet private weak var credsFieldsStackView: UIStackView!
    @IBOutlet private weak var emailContainerView: UIView!
    @IBOutlet private weak var passwordContainerView: UIView!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var authButton: UIButton!
    
    @IBOutlet private weak var otherSigningOptionsPromptLabel: UILabel!
    @IBOutlet private weak var continuePromptLabel: UILabel!
    @IBOutlet private weak var credsPromptLabel: UILabel!
    
    @IBOutlet private weak var appleButtonContainerView: UIView!
    @IBOutlet private weak var facebookButtonContainerView: UIView!
    @IBOutlet private weak var facebookButton: UIButton!
    
    @IBOutlet private weak var googleButtonContainerView: UIView!
    @IBOutlet private weak var googleButton: UIButton!
    
    @IBOutlet private weak var changeAuthStatePromptLabel: UILabel!
    @IBOutlet private weak var changeAuthStateButton: UIButton!
    
    @IBOutlet private weak var passwordContainerHeightConstraint: NSLayoutConstraint!
    
    private var emailSimpleField = SimpleField.view
    private var passwordSimpleField = SimpleField.view
    
    private let passwordConatinerHeightConstant: CGFloat = 65
    private let passwordFailedRuleMessageHeight: CGFloat = 13
    
    static let identifier = "AuthVC"
    
    weak var delegate: AuthVCDelegate?
    
    var state: State? {
        didSet {
            guard let requiredState = state else { return }
            loadViewIfNeeded()
            setupUI(for: requiredState)
        }
    }
    
    private var credsType: CredsType? {
        didSet {
            guard let requiredCredsType = credsType else { return }
            updateCreds(for: requiredCredsType)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        credsType = .email
        setupOtherSigningOptions()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.didTapBackButton(self)
    }
    
    @IBAction func didTapForgotPasswordButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapAuthButton(_ sender: UIButton) {
        handleAuth()
        if emailSimpleField.valueTextField.isFirstResponder {
            emailSimpleField.valueTextField.resignFirstResponder()
        } else if passwordSimpleField.valueTextField.isFirstResponder {
            passwordSimpleField.valueTextField.resignFirstResponder()
        }
    }
    
    @IBAction func didTapFacebookButton(_ sender: UIButton) {
        delegate?.didTapFBButton(self)
    }
    
    @IBAction func didTapGoogleButton(_ sender: UIButton) {
        delegate?.didTapGoogleButton(self)
    }
    
    @IBAction func didTapChangeAuthStateButton(_ sender: UIButton) {
        guard let requiredState = state else { return }
        
        switch requiredState {
        case .signIn: state = .signUp
        case .signUp: state = .signIn
        }
    }
    
    func show(emailError: String) {
        self.emailSimpleField.state = .error(reason: emailError)
    }
    
    func show(passwordError: String) {
        self.passwordSimpleField.state = .error(reason: passwordError)
    }
    
    func updatePasswordContainerHeight(failedRulesCount: Int) {
        passwordContainerHeightConstraint.constant = passwordConatinerHeightConstant + (CGFloat(failedRulesCount) * passwordFailedRuleMessageHeight)
    }
    
    @discardableResult
    func validatePassword(password: String) -> Bool {
        
        guard !password.isEmpty else {
            show(passwordError: "Password field is empty")
            return false
        }
        
        let validationResult = password.isValidPassword()
        if let errors = validationResult.1 {
            updatePasswordContainerHeight(failedRulesCount: errors.count)
            show(passwordError: errors.joined(separator: "\n"))
            return false
        } else {
            passwordSimpleField.state = .normal
            return true
        }
    }
}

// MARK: -
// MARK: Private
private extension AuthVC {
    
    func handleAuth() {
        guard let requiredState = state,
              let requiredCredsType = credsType else { return }
        
        switch requiredState {
        case .signIn:
            let creds: Credentials
            if passwordContainerView.isHidden {
                creds = .phone(emailSimpleField.text)
            } else {
                creds = .email(Credentials.EmailCreds(email: emailSimpleField.text, password: passwordSimpleField.text))
            }
            delegate?.didTapSignInButton(self, credentials: creds)
        case .signUp:
            guard !emailSimpleField.text.isEmpty else {
                emailSimpleField.state = .error(reason: "Email field is empty")
                return
            }
            
            if emailSimpleField.text.isValidEmail() {
                
                let emailCreds = Credentials.EmailCreds(email: emailSimpleField.text, password: nil)
                let creds = Credentials.email(emailCreds)
                delegate?.didTapContinueButton(self, credentials: creds)
                return
            }
            
            if emailSimpleField.text.isValidPhone() {
                let creds = Credentials.phone(emailSimpleField.text)
                delegate?.didTapContinueButton(self, credentials: creds)
                return
            }
            
            let errorMessage = (requiredCredsType == .email) ? AuthRouter.Err.invalidEmailFormat.message :
                                                               AuthRouter.Err.invalidPhoneFormat.message
            
            emailSimpleField.state = .error(reason: errorMessage)
        }
    }
    
    func setupOtherSigningOptions() {
        
        // Apple
        let appleButton = ASAuthorizationAppleIDButton()
        (appleButton as UIControl).cornerRadius = 10
        appleButton.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButtonContainerView.addSubview(appleButton)
        appleButton.snp.makeConstraints { $0.top.leading.trailing.bottom.equalToSuperview() }
        
        // Facebook
        facebookButton.layer.cornerRadius = 10
        
        // Google
        googleButton.layer.cornerRadius = 10
    }
    
    @objc func didTapAppleButton() {
        delegate?.didTapAppleButton(self)
    }
    
    func setupUI(for state: State) {
        
        authButton.layer.cornerRadius = 15
        setupEmailSimpleField(for: state)
        credsFieldsStackView.setCustomSpacing(7, after: credsPromptLabel)
        
        let isSignIn = (state == .signIn)
        
        authSmallTitleLabel.text = isSignIn ? "Sign In" : "Sign Up"
        authTitleLabel.text = isSignIn ? "Sign In" : "Sign Up"
        credsPromptLabel.text = isSignIn ? "Sign in to view your profile and configure settings" : "Enter your email or phone number to create an account"
        otherSigningOptionsPromptLabel.text = isSignIn ? "or sign in with" : "or continue with"
        changeAuthStatePromptLabel.text = isSignIn ? "Don't have an account?" : "Already have an account?"
        
        authButton.setTitle(isSignIn ? "Sign In" : "Continue", for: .normal)
        
        changeAuthStateButton.setTitle(isSignIn ? "Sign Up" : "Sign In", for: .normal)
        
        passwordContainerView.isHidden = !isSignIn
        forgotPasswordButton.isHidden = !isSignIn
        
        if isSignIn { setupPasswordSimpleField() }
        
        emailSimpleField.state = .normal
        emailSimpleField.text = ""
        passwordSimpleField.state = .normal
        passwordSimpleField.text = ""
    }
    
    func animateTextTransition(label: UILabel,
                               signInText: String,
                               signUpText: String,
                               isSignIn: Bool) {
        UIView.transition(
            with: label,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: {
                label.text = isSignIn ? signInText : signUpText
            })
    }
    
    func setupEmailSimpleField(for state: State) {
        
        if state == .signUp {
            emailSimpleField.removePhoneEmailSwitcher()
        } else {
            emailSimpleField.addPhoneEmailSwitcher()
        }
        
        guard emailContainerView.subviews.isEmpty else { return }
        
        emailContainerView.addSubview(emailSimpleField)
        
        if state == .signIn {
            emailSimpleField.didTapPhoneIconAction = { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.passwordContainerView.isHidden = false
                    UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveLinear) {
                        self?.passwordSimpleField.alpha = 1
                    }
                }
                self?.emailSimpleField.changePlaceholder(to: "Email")
            }
            
            emailSimpleField.didTapEmailIconAction = { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.passwordSimpleField.alpha = 0
                    UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveLinear) {
                        self?.passwordContainerView.isHidden = true
                    }
                }
                self?.emailSimpleField.changePlaceholder(to: "Phone number")
            }
        }
        
        emailSimpleField.delegate = self
        emailSimpleField.translatesAutoresizingMaskIntoConstraints = false
        emailSimpleField.snp.makeConstraints { $0.top.bottom.leading.trailing.equalToSuperview() }
        
        emailSimpleField.valueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let placeHolder = (state == .signIn) ? "Email" : "Email or phone number"
        let emailSettings = SimpleField.Settings(placeholder: NSAttributedString(string: placeHolder), returnKey: .done, isSecureEntry: false)
        emailSimpleField.settings = emailSettings
    }
    
    func setupPasswordSimpleField() {
        guard passwordContainerView.subviews.isEmpty else { return }
        
        passwordContainerView.addSubview(passwordSimpleField)
        passwordSimpleField.delegate = self
        passwordSimpleField.translatesAutoresizingMaskIntoConstraints = false
        passwordSimpleField.snp.makeConstraints { $0.top.bottom.leading.trailing.equalToSuperview() }
        
        passwordSimpleField.valueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let emailSettings = SimpleField.Settings(placeholder: NSAttributedString(string: "Password"), returnKey: .done, isSecureEntry: true)
        passwordSimpleField.settings = emailSettings
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == emailSimpleField.valueTextField {
            guard case .error = emailSimpleField.state else { return }
            
            guard !emailSimpleField.text.isEmpty else {
                show(emailError: "Email field is empty")
                return
            }
            
            guard emailSimpleField.text.isValidEmail() else {
                show(emailError: "Invalid email format")
                return
            }
            
            emailSimpleField.state = .normal
        }
        
        if textField == passwordSimpleField.valueTextField {
            guard case .error = passwordSimpleField.state else { return }
            
            guard !passwordSimpleField.text.isEmpty else {
                show(passwordError: "Password field is empty")
                return
            }
            
            validatePassword(password: passwordSimpleField.text)
        }
    }
    
    func updateCreds(for credsType: CredsType) {
        
        switch credsType {
        case .email:
            emailSimpleField.changePlaceholder(to: "email")
            
            emailSimpleField.valueTextField.keyboardType = .default
            removeDoneButtonFromCredsKeyboard()
            if state != .signUp {
                passwordContainerView.isHidden = false
            }
        case .phone:
            emailSimpleField.changePlaceholder(to: "phone")

            emailSimpleField.valueTextField.keyboardType = .phonePad
            addDoneButtonOnCredsKeyboard()
            passwordContainerView.isHidden = true
        }
        
        if emailSimpleField.valueTextField.isFirstResponder {
            emailSimpleField.valueTextField.resignFirstResponder()
        }
        
        if passwordSimpleField.valueTextField.isFirstResponder {
            passwordSimpleField.valueTextField.resignFirstResponder()
        }
        
        emailSimpleField.text = ""
    }
    
    func addDoneButtonOnCredsKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.didTapDoneButton))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        emailSimpleField.valueTextField.inputAccessoryView = doneToolbar
    }
    
    func removeDoneButtonFromCredsKeyboard() {
        emailSimpleField.valueTextField.inputAccessoryView = nil
    }
    
    @objc func didTapDoneButton() {
        handleAuth()
        emailSimpleField.valueTextField.resignFirstResponder()
    }
}

// MARK: -
// MARK: UITextfieldDelegate
extension AuthVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
