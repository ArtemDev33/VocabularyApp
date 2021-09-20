//
//  OneTimeCodeTextField.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 06.09.2021.
//

import UIKit

final class OneTimeCodeTextField: UITextField {
    
    private var digitLabels = [UILabel]()
    private var isConfigured = false
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    
    var didEnterLastDigit: ((String) -> Void)?
    var defaultCharacter = "-"
    
    func configure(withSlotCount slotCount: Int = 6) {
        guard !isConfigured else { return }
        
        isConfigured = true
        configureTextField()
        
        let labelsStackView = createLabelsStackView(with: slotCount)
        addSubview(labelsStackView)
        
        addGestureRecognizer(tapRecognizer)
        
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: -
// MARK: Private
private extension OneTimeCodeTextField {
    func configureTextField() {
        tintColor = .clear
        textColor = .clear
        backgroundColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        delegate = self
        
        addDoneButtonOnCredsKeyboard()
    }
    
    func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        for _ in 0..<count {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 40)
            label.isUserInteractionEnabled = true
            label.text = defaultCharacter
            
            stackView.addArrangedSubview(label)
            digitLabels.append(label)
        }
        
        return stackView
    }
    
    @objc
    func textDidChange() {
        guard let text = self.text, text.count <= digitLabels.count else { return }
        
        for i in 0..<digitLabels.count {
            let currentLabel = digitLabels[i]
            
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                currentLabel.text = String(text[index])
            } else {
                currentLabel.text = defaultCharacter
            }
        }
        
        if text.count == digitLabels.count {
            didEnterLastDigit?(text)
        }
    }
    
    func addDoneButtonOnCredsKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.didTapDoneButton))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        inputAccessoryView = doneToolbar
    }
    
    @objc func didTapDoneButton() {
        resignFirstResponder()
    }
}

// MARK: -
// MARK: UiTextFieldDelegate
extension OneTimeCodeTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let charsCount = textField.text?.count else { return false }
        return charsCount < digitLabels.count || string == ""
    }
}
