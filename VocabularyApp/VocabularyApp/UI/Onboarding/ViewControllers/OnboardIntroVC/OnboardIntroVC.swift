//
//  OnboardIntroVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 28.04.2021.
//

import UIKit

// MARK: -
// MARK: Delegate
protocol OnboardIntroVCDelegate: AnyObject {
    func didTapStartButton(controller: OnboardIntroVC)
}

// MARK: -
// MARK: Class declaration
final class OnboardIntroVC: UIViewController {
    
    @IBOutlet private weak var startButton: UIButton!
    
    static let identifier = "OnboardIntroVC"
    
    weak var delegate: OnboardIntroVCDelegate?
    
    var storageService: StorageManager!
    var networkDictionaryService: NetworkDictionaryService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    @IBAction func didTapStartButton(_ sender: UIButton) {
        delegate?.didTapStartButton(controller: self)        
    }
}

// MARK: -
// MARK: Private
private extension OnboardIntroVC {
    func configureUI() {
        configureStartButton()
    }
    
    func configureStartButton() {
        startButton.layer.cornerRadius = 10
    }
}
