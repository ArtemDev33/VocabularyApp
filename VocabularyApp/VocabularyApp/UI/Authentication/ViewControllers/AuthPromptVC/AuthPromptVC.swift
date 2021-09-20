//
//  AuthPromptVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.07.2021.
//

import UIKit

// MARK: -
// MARK: Delegate
protocol AuthPromptVCDelegate: AnyObject {
    func didTapBackButton(controller: AuthPromptVC)
    func didTapSignUpButton(controller: AuthPromptVC)
    func didTapSignInButton(controller: AuthPromptVC)
}

// MARK: -
// MARK: Class declaration
final class AuthPromptVC: UIViewController {
    
    @IBOutlet private weak var signUpButton: UIButton!
    static let identifier = "AuthPromptVC"

    weak var delegate: AuthPromptVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.didTapBackButton(controller: self)
    }
    
    @IBAction func didTapSignUpButton(_ sender: UIButton) {
        delegate?.didTapSignUpButton(controller: self)
    }
    
    @IBAction func didTapSignInButton(_ sender: UIButton) {
        delegate?.didTapSignInButton(controller: self)
    }
}

// MARK: -
// MARK: Private
private extension AuthPromptVC {
    func setupUI() {
        signUpButton.layer.cornerRadius = 15
    }
}

extension AuthPromptVC: UIGestureRecognizerDelegate {
    
}
