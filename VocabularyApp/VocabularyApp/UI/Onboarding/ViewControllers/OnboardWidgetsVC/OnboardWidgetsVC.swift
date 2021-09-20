//
//  OnboardWidgetsVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 28.04.2021.
//

import UIKit

// MARK: -
// MARK: Delegate
protocol OnboardWidgetsVCDelegate: AnyObject {
    func didTapGotItButton(controller: OnboardWidgetsVC)
}

// MARK: -
// MARK: Class declaration
final class OnboardWidgetsVC: UIViewController {
    @IBOutlet private weak var gotItButton: UIButton!
    
    static let identifier = "OnboardWidgetsVC"
    
    weak var delegate: OnboardWidgetsVCDelegate?
    
    var storageService: StorageManager!
    var networkDictionaryService: NetworkDictionaryService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCornerRadiuses()
    }
    
    @IBAction func didTapGotItButton(_ sender: UIButton) {
        delegate?.didTapGotItButton(controller: self)
    }
}

// MARK: -
// MARK: Private
private extension OnboardWidgetsVC {
    func configureCornerRadiuses() {
        gotItButton.layer.cornerRadius = 10
    }
}
