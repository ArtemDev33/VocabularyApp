//
//  SimpleField.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.07.2021.
//

import UIKit

// MARK: -
// MARK: View Settings
extension SimpleField {
    
    enum State {
        case normal
        case selected
        case editing
        case error(reason: String)
    }
    
    struct StyleSettings {
        
        let containerBackgroundColor: UIColor
        let borderColorForNormalState: UIColor
        
        init(containerBackgroundColor: UIColor = Design.Color.white,
             borderColorForNormalState: UIColor = Design.Color.darkerGray) {
            
            self.containerBackgroundColor = containerBackgroundColor
            self.borderColorForNormalState = borderColorForNormalState
        }
    }
    
    struct Settings {
        
        let placeholder: NSAttributedString
        let capitalization: UITextAutocapitalizationType
        let returnKey: UIReturnKeyType
        let keyboardType: UIKeyboardType
        let isSecureEntry: Bool
        let styleSettings: StyleSettings

        init(placeholder: NSAttributedString = .init(string: ""),
             capitalization: UITextAutocapitalizationType = .none,
             returnKey: UIReturnKeyType = .done,
             keyboardType: UIKeyboardType = .default,
             isSecureEntry: Bool = false,
             styleSettings: StyleSettings = StyleSettings()) {
            
            self.placeholder = placeholder
            self.capitalization = capitalization
            self.returnKey = returnKey
            self.keyboardType = keyboardType
            self.isSecureEntry = isSecureEntry
            self.styleSettings = styleSettings
        }
    }
}

// MARK: -
// MARK: Class declaration
final class SimpleField: UIView {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var textFieldContainer: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    private var phoneEmailSwitcherButton: UIButton?
    
    static let identifier = "SimpleField"
    static var view: SimpleField {
        Bundle.main.loadNibNamed(SimpleField.identifier, owner: self, options: nil)?.first as! SimpleField
    }
    
    var didTapPhoneIconAction: (() -> ())?
    var didTapEmailIconAction: (() -> ())?
    
    var text: String {
        get { self.textField.text ?? "" }
        set { self.textField.text = newValue }
    }
    
    var valueTextField: UITextField {
        textField
    }
    
    var settings: SimpleField.Settings = .init() {
        didSet {
            self.updateTextField(settings: settings)
        }
    }
    
    var delegate: UITextFieldDelegate? {
        get { self.textField.delegate }
        set { self.textField.delegate = newValue }
    }
    
    var state: SimpleField.State = .normal {
        didSet {
            self.updateUI(with: state)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    func disableSmartInsert() {
        self.textField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
    }
    
    func isContain(textField: UITextField) -> Bool {
        
        if textField === self.textField {
            return true
        }
        
        return false
    }
    
    func changePlaceholder(to string: String) {
        textField.attributedPlaceholder = NSAttributedString(string: string)
    }
    
    func resignFirstResponderIfIsOne() {
        if valueTextField.isFirstResponder {
            valueTextField.resignFirstResponder()
        }
    }
    
    func addPhoneEmailSwitcher() {
        guard phoneEmailSwitcherButton == nil else { return }
        
        let buttonContainer = UIView()
        buttonContainer.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        buttonContainer.backgroundColor = .clear
        
        phoneEmailSwitcherButton = UIButton(type: .custom)
        phoneEmailSwitcherButton!.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        phoneEmailSwitcherButton!.setBackgroundImage(UIImage(named: "at_icon"), for: .normal)
        phoneEmailSwitcherButton!.addTarget(self, action: #selector(phoneEmailSwitcherButtonDidTap), for: .touchUpInside)
        
        buttonContainer.addSubview(phoneEmailSwitcherButton!)
        phoneEmailSwitcherButton!.center = buttonContainer.center
        
        textField.rightView = buttonContainer
        textField.rightViewMode = .unlessEditing
    }
    
    func removePhoneEmailSwitcher() {
        phoneEmailSwitcherButton = nil
        textField.rightView = nil
    }
}

// MARK: -
// MARK: Private
private extension SimpleField {
    
    func setupUI() {
        self.textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.textField.textColor = Design.Color.darkerGray
        self.textField.clearButtonMode = .whileEditing
        self.updateTextField(settings: settings)
        self.textFieldContainer.layer.borderWidth = 1.0
        self.textFieldContainer.layer.cornerRadius = 22.0
        self.textFieldContainer.clipsToBounds = true
        self.errorLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        self.errorLabel.text = ""
        self.errorLabel.isHidden = true
        self.errorLabel.textColor = Design.Color.red
    }
    
    func updateUI(with state: SimpleField.State) {
        
        switch state {
        case .normal:
            self.textFieldContainer.layer.borderColor = settings.styleSettings.borderColorForNormalState.cgColor
            self.errorLabel.isHidden = true
            self.errorLabel.text = nil
        case .selected:
            if !self.textField.isFirstResponder {
                self.textField.becomeFirstResponder()
            }
            self.textFieldContainer.layer.borderColor = settings.styleSettings.borderColorForNormalState.cgColor
        case .editing:
            if !self.textField.isFirstResponder {
                self.textField.becomeFirstResponder()
            }
            self.textFieldContainer.layer.borderColor = settings.styleSettings.borderColorForNormalState.cgColor
            self.errorLabel.isHidden = true
            self.errorLabel.text = nil
            
        case .error(let reason):
            
            self.errorLabel.alpha = 0.0
            self.errorLabel.text = reason
            self.errorLabel.isHidden = false
            UIView.animate(withDuration: 0.7) {
                self.errorLabel.alpha = 1.0
            }
            self.textFieldContainer.layer.borderColor = Design.Color.red.cgColor
        }
    }
    
    func updateTextField(settings: Settings) {
        
        self.textField.attributedPlaceholder = settings.placeholder
        self.textField.autocapitalizationType = settings.capitalization
        self.textField.returnKeyType = settings.returnKey
        self.textField.isSecureTextEntry = settings.isSecureEntry
        self.textField.keyboardType = settings.keyboardType
        
        self.backgroundColor = settings.styleSettings.containerBackgroundColor
    }
    
    @objc func phoneEmailSwitcherButtonDidTap() {
        guard let image = phoneEmailSwitcherButton?.currentBackgroundImage else { return }
        if image == UIImage(named: "at_icon") {
            phoneEmailSwitcherButton?.setBackgroundImage(UIImage(named: "phone_icon"), for: .normal)
            didTapEmailIconAction?()
        } else {
            phoneEmailSwitcherButton?.setBackgroundImage(UIImage(named: "at_icon"), for: .normal)
            didTapPhoneIconAction?()
        }
    }
}
