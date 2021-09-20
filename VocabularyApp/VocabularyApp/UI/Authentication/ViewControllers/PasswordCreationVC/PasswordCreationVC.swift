//
//  PasswordCreationVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 02.09.2021.
//

import UIKit

// MARK: -
// MARK: Delegate
protocol PasswordCreationVCDelegate: AnyObject {
    func didTapBackButton(_ vc: PasswordCreationVC)
    func didCreatePassword(_ vc: PasswordCreationVC, credentials: Credentials.EmailCreds)
}

// MARK: -
// MARK: Class declaration
final class PasswordCreationVC: UIViewController {

    @IBOutlet private weak var firstPasswordContainerView: UIView!
    @IBOutlet private weak var secondPasswordContainerView: UIView!
    @IBOutlet private weak var continueButton: UIButton!
    
    @IBOutlet private weak var firstPasswordContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var secondPasswordContainerHeightConstraint: NSLayoutConstraint!
    
    private var firstPasswordSimpleField = SimpleField.view
    private var secondPasswordSimpleField = SimpleField.view
    
    static let identifier = "PasswordCreationVC"
    
    weak var delegate: PasswordCreationVCDelegate?
    
    var emailCreds: Credentials.EmailCreds?
    
    private let passwordConatinerHeightConstant: CGFloat = 65
    private let passwordFailedRuleMessageHeight: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.didTapBackButton(self)
    }
    
    @IBAction func didTapContinueButton(_ sender: UIButton) {
        firstPasswordSimpleField.resignFirstResponderIfIsOne()
        secondPasswordSimpleField.resignFirstResponderIfIsOne()
        
        guard validatePassword(
            simpleField: firstPasswordSimpleField,
            containerHeightConstraint: firstPasswordContainerHeightConstraint
        ) else { return }
        
        guard var creds = emailCreds else {
            showAlert(title: "Error", message: "Email info missing")
            return
        }
        
        if firstPasswordSimpleField.text == secondPasswordSimpleField.text {
            creds.password = firstPasswordSimpleField.text
            delegate?.didCreatePassword(self, credentials: creds)
        } else {
            show(passwordError: "Passwords don't match", field: secondPasswordSimpleField)
        }
    }
}

// MARK: -
// MARK: Private
private extension PasswordCreationVC {
    func setupUI() {
        setupPasswordSimpleFields()
        continueButton.layer.cornerRadius = 15
    }
    
    func setupPasswordSimpleFields() {
        guard firstPasswordContainerView.subviews.isEmpty,
              secondPasswordContainerView.subviews.isEmpty else { return }
        
        firstPasswordContainerView.addSubview(firstPasswordSimpleField)
        firstPasswordSimpleField.delegate = self
        firstPasswordSimpleField.translatesAutoresizingMaskIntoConstraints = false
        firstPasswordSimpleField.snp.makeConstraints { $0.top.bottom.leading.trailing.equalToSuperview() }
        //firstPasswordSimpleField.valueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let firstPasswordSettings = SimpleField.Settings(placeholder: NSAttributedString(string: "Password"), returnKey: .done, isSecureEntry: true)
        firstPasswordSimpleField.settings = firstPasswordSettings
        
        secondPasswordContainerView.addSubview(secondPasswordSimpleField)
        secondPasswordSimpleField.delegate = self
        secondPasswordSimpleField.translatesAutoresizingMaskIntoConstraints = false
        secondPasswordSimpleField.snp.makeConstraints { $0.top.bottom.leading.trailing.equalToSuperview() }
        
        let secondPasswordSettings = SimpleField.Settings(placeholder: NSAttributedString(string: "Repeat password"), returnKey: .done, isSecureEntry: true)
        secondPasswordSimpleField.settings = secondPasswordSettings
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        guard case .error = firstPasswordSimpleField.state else { return }
        validatePassword(simpleField: firstPasswordSimpleField, containerHeightConstraint: firstPasswordContainerHeightConstraint)
        
    }
    
    func updatePasswordContainerHeight(failedRulesCount: Int, constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.4) {
            if failedRulesCount == 0 {
                constraint.constant = self.passwordConatinerHeightConstant
            } else {
                constraint.constant = self.passwordConatinerHeightConstant + (CGFloat(failedRulesCount) * self.passwordFailedRuleMessageHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func show(passwordError: String, field: SimpleField) {
        field.state = .error(reason: passwordError)
    }
    
    @discardableResult
    func validatePassword(simpleField: SimpleField, containerHeightConstraint: NSLayoutConstraint) -> Bool {
        
        let password = simpleField.text
        
        guard !password.isEmpty else {
            show(passwordError: "Password field is empty", field: firstPasswordSimpleField)
            return false
        }
        
        let validationResult = password.isValidPassword()
        if let errors = validationResult.1 {
            updatePasswordContainerHeight(failedRulesCount: errors.count, constraint: containerHeightConstraint)
            show(passwordError: errors.joined(separator: "\n"), field: simpleField)
            return false
        } else {
            simpleField.state = .normal
            return true
        }
    }
}

// MARK: -
// MARK: UITextfieldDelegate
extension PasswordCreationVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === firstPasswordSimpleField.valueTextField {
            firstPasswordSimpleField.state = .normal
            if firstPasswordContainerHeightConstraint.constant != passwordConatinerHeightConstant {
                updatePasswordContainerHeight(failedRulesCount: 0, constraint: firstPasswordContainerHeightConstraint)
            }
        } else if textField === secondPasswordSimpleField.valueTextField {
            secondPasswordSimpleField.state = .normal
            if secondPasswordContainerHeightConstraint.constant != passwordConatinerHeightConstant {
                updatePasswordContainerHeight(failedRulesCount: 0, constraint: secondPasswordContainerHeightConstraint)
            }
        }
    }
}
