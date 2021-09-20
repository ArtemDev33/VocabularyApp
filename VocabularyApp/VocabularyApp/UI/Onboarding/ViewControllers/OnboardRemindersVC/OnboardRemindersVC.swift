//
//  OnboardRemindersVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 28.04.2021.
//

import UIKit

// MARK: -
// MARK: Delegate
protocol OnboardRemindersVCDelegate: AnyObject {
    func didTapContinueButton(controller: OnboardRemindersVC)
}

// MARK: -
// MARK: Class declaration
final class OnboardRemindersVC: UIViewController {
    @IBOutlet private weak var reminderView: UIView!
    
    @IBOutlet private weak var selectorsStackView: UIStackView!
    @IBOutlet private weak var selectorsHintLabel: UILabel!
    @IBOutlet private weak var howManySelectorView: UIView!
    @IBOutlet private weak var startAtSelectorView: UIView!
    @IBOutlet private weak var endAtSelectorView: UIView!
    
    @IBOutlet private weak var howManyTitleLabel: UILabel!
    @IBOutlet private weak var startAtTitleLabel: UILabel!
    @IBOutlet private weak var endAtTitleLabel: UILabel!
    
    @IBOutlet private weak var howManyLabel: UILabel!
    @IBOutlet private weak var startAtLabel: UILabel!
    @IBOutlet private weak var endAtLabel: UILabel!
    
    @IBOutlet private weak var howManyHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var startAtHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var endAtHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var howManyButtonsWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var startAtButtonsWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var endAtButtonsWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var continueButton: UIButton!
    
    static let identifier = "OnboardRemindersVC"
    
    weak var delegate: OnboardRemindersVCDelegate?
    
    var storageService: StorageManager!
    var networkDictionaryService: NetworkDictionaryService!
    
    private let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDateFormatter()
    }
    
    @IBAction func didTapContinueButton(_ sender: UIButton) {
        delegate?.didTapContinueButton(controller: self)
    }
    
    @IBAction func didTapMinusHowManyButton(_ sender: UIButton) {
        guard let labelString = howManyLabel.text,
              let labelNumber = integerFromString(labelString),
              labelNumber > 1 else { return }
        
        howManyLabel.text = String(labelNumber - 1) + "x"
    }
    
    @IBAction func didTapPlusHowManyButton(_ sender: UIButton) {
        guard let labelString = howManyLabel.text,
              let labelNumber = integerFromString(labelString),
              labelNumber < 51 else { return }
        
        howManyLabel.text = String(labelNumber + 1) + "x"
    }
    
    @IBAction func didTapMinusStartAtButton(_ sender: UIButton) {
        guard let labelString = startAtLabel.text,
              var date = formatter.date(from: labelString) else { return }
        
        date.addTimeInterval(-30 * 60)
        startAtLabel.text = formatter.string(from: date)
    }
    
    @IBAction func didTapPlusStartAtButton(_ sender: UIButton) {
        guard let labelString = startAtLabel.text,
              var date = formatter.date(from: labelString) else { return }
        
        date.addTimeInterval(30 * 60)
        startAtLabel.text = formatter.string(from: date)
    }
    
    @IBAction func didTapMinusEndAtButton(_ sender: UIButton) {
        guard let labelString = endAtLabel.text,
              var date = formatter.date(from: labelString) else { return }
        
        date.addTimeInterval(-30 * 60)
        endAtLabel.text = formatter.string(from: date)
    }
    
    @IBAction func didTapPlusEndAtButton(_ sender: UIButton) {
        guard let labelString = endAtLabel.text,
              var date = formatter.date(from: labelString) else { return }
        
        date.addTimeInterval(30 * 60)
        endAtLabel.text = formatter.string(from: date)
    }
}

// MARK: -
// MARK: Private
private extension OnboardRemindersVC {
    func configureUI() {
        configureCornerRadiuses()
        configureSelectorsStackView()
    }
    
    func configureCornerRadiuses() {
        reminderView.layer.cornerRadius = 10
        howManySelectorView.layer.cornerRadius = 6
        startAtSelectorView.layer.cornerRadius = 6
        endAtSelectorView.layer.cornerRadius = 6
        continueButton.layer.cornerRadius = 10
    }
    
    func configureSelectorsStackView() {
        selectorsStackView.setCustomSpacing(15, after: selectorsHintLabel)
        
        let screenWidth = UIScreen.main.bounds.width
        if screenWidth < 375 {
            let ratio = (screenWidth / 375) - 0.05
            howManyHeightConstraint.constant *= ratio
            startAtHeightConstraint.constant *= ratio
            endAtHeightConstraint.constant *= ratio
            
            howManyButtonsWidthConstraint.constant *= ratio
            startAtButtonsWidthConstraint.constant *= ratio
            endAtButtonsWidthConstraint.constant *= ratio
            
            howManyLabel.font = howManyLabel.font.withSize(howManyLabel.font.pointSize * ratio)
            startAtLabel.font = startAtLabel.font.withSize(startAtLabel.font.pointSize * ratio)
            endAtLabel.font = endAtLabel.font.withSize(endAtLabel.font.pointSize * ratio)
            
            howManyTitleLabel.font = howManyTitleLabel.font.withSize(howManyTitleLabel.font.pointSize * ratio)
            startAtTitleLabel.font = startAtTitleLabel.font.withSize(startAtTitleLabel.font.pointSize * ratio)
            endAtTitleLabel.font = endAtTitleLabel.font.withSize(endAtTitleLabel.font.pointSize * ratio)
        }
    }
    
    func integerFromString(_ string: String) -> Int? {
        let array = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        
        for item in array {
            guard let number = Int(item) else { continue }
            
            return number
        }
        
        return nil
    }
    
    func configureDateFormatter() {
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm a"
    }
}
