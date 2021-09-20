//
//  PhoneVerificationVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 06.08.2021.
//

import UIKit

// MARK: -
// MARK: Delegate
protocol PhoneVerificationVCDelegate: AnyObject {
    func didTapBackButton(_ controller: PhoneVerificationVC)
    func didEnterLastDigit(_ controller: PhoneVerificationVC, code: String)
    func didTapResendOtp(_ controller: PhoneVerificationVC, phoneNumber: String)
}

// MARK: -
// MARK: Class declaration
final class PhoneVerificationVC: UIViewController {
    
    @IBOutlet private weak var oneTimeCodeTextField: OneTimeCodeTextField!
    @IBOutlet private weak var resendCodeButton: UIButton!
    @IBOutlet private weak var timerHintLabel: UILabel!
    @IBOutlet private weak var timerLabel: UILabel!
    
    static let identifier = "PhoneVerificationVC"

    weak var delegate: PhoneVerificationVCDelegate?
    
    var phoneNumber: String = ""
    let timerTime = 60
    var timer: Timer?
    var totalTime = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startOtpTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        oneTimeCodeTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopOtpTimer()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        stopOtpTimer()
        delegate?.didTapBackButton(self)
    }
    
    @IBAction func didTapResendOtp(_ sender: UIButton) {
        delegate?.didTapResendOtp(self, phoneNumber: phoneNumber)
        startOtpTimer()
    }
}

// MARK: -
// MARK: Private
private extension PhoneVerificationVC {
    
    func setupUI() {
        oneTimeCodeTextField.didEnterLastDigit = { [weak self] code in
            guard let self = self else { return }
            self.delegate?.didEnterLastDigit(self, code: code)
        }
        oneTimeCodeTextField.configure()
    }
    
    @objc func didTapDoneButton() {
        oneTimeCodeTextField.resignFirstResponder()
    }
    
    func startOtpTimer() {
        guard timer == nil else { return }
        
        resendCodeButton.isUserInteractionEnabled = false
        resendCodeButton.alpha = 0.6
        timerLabel.text = "01:00"
        timerLabel.isHidden = false
        timerHintLabel.isHidden = false
        
        totalTime = timerTime
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateTimer() {
        print(totalTime)
        timerLabel.text = timeFormatted(totalTime)
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            hideOtpTimer()
        }
    }
    
    func stopOtpTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func hideOtpTimer() {
        
        stopOtpTimer()
        
        DispatchQueue.main.async {
            self.resendCodeButton.isUserInteractionEnabled = true
            self.resendCodeButton.alpha = 1
            self.timerLabel.isHidden = true
            self.timerHintLabel.isHidden = true
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
