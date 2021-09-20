//
//  ProfileVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 04.08.2021.
//

import UIKit

protocol ProfileVCDelegate: AnyObject {
    func didTapSignOutButton(_ controller: ProfileVC)
}

// MARK: -
// MARK: Class declaration
final class ProfileVC: UIViewController {
    
    static let identifier = "ProfileVC"
    
    weak var delegate: ProfileVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapSignOutButton(_ sender: UIButton) {
        delegate?.didTapSignOutButton(self)
    }
}
