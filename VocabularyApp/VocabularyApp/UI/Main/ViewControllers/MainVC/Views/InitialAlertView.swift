//
//  InitialAlertView.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 21.05.2021.
//

import UIKit

// MARK: -
// MARK: InitialAlertViewDelegate
protocol InitialAlertViewDelegate: AnyObject {
    func didTapLetsDoItButton(_ view: InitialAlertView)
    func didTapDeleteButton(_ view: InitialAlertView)
}

// MARK: -
// MARK: Class declaration
final class InitialAlertView: UIView {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var letsDoItButton: UIButton!
    
    static let identifier: String = "InitialAlertView"
    
    weak var delegate: InitialAlertViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    @IBAction func didTapLetsDoItButton(_ sender: UIButton) {
        delegate?.didTapLetsDoItButton(self)
    }
    
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        delegate?.didTapDeleteButton(self)
    }
}

// MARK: -
// MARK: Private
private extension InitialAlertView {
    func configureUI() {
        containerView.layer.cornerRadius = 10
        letsDoItButton.layer.cornerRadius = 10
    }
}
