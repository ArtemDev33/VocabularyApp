//
//  SearchVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 30.04.2021.
//

import UIKit
import Alamofire
import PromiseKit

// MARK: -
// MARK: Delegate
protocol SearchVCDelegate: AnyObject {
    func didTapCancelButton(controller: SearchVC)
}

// MARK: -
// MARK: Class declaration
final class SearchVC: UIViewController {
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var searchButtonContainerView: UIView!
    @IBOutlet private weak var searchButton: UIButton!
    
    @IBOutlet private weak var emptySearchImage: UIImageView!
    @IBOutlet private weak var searchInstructionStack: UIStackView!
    
    @IBOutlet private weak var emptySearchImageHeightConstraint: NSLayoutConstraint!
        
    static let id = "SearchVC"
    
    weak var delegate: SearchVCDelegate?
    
    var storageService: StorageManager!
    var networkDictionaryService: NetworkDictionaryService!
    
    var newPushWord: String? {
        didSet {
            guard let word = newPushWord,
                  isViewLoaded else { return }
            
            searchWord(text: word)
            newPushWord = nil
        }
    }
    
    private var searchedWordView: SearchedWordView?
    private var searchedWord: Word?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        storageService.subscribeForUpdates(observer: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if newPushWord != nil {
            self.emptySearchImage.isHidden = true
            self.searchInstructionStack.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let word = newPushWord else { return }
        self.searchWord(text: word)
        self.newPushWord = nil
    }
    
    deinit {
        storageService.unsubscribeFromUpdates(observer: self)
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        delegate?.didTapCancelButton(controller: self)
    }
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        guard let text = searchTextField.text else { return }
        searchWord(text: text)
    }
}

// MARK: -
// MARK: Private
private extension SearchVC {
    
    func searchWord(text: String) {
        self.emptySearchImage.isHidden = true
        self.searchInstructionStack.isHidden = true
        showActivityIndicator()
        
        firstly {
            networkDictionaryService.word(word: text)
        }.done(on: DispatchQueue.main) { word in
            self.searchedWord = word
            guard self.searchedWordView != nil else {
                self.addSearchWordView(word)
                return
            }
            let isAlreadyAdded = self.storageService.contains(word: word.word)
            self.searchedWordView?.vmodel = SearchedWordView.ViewModel(searchedWord: word, isAlreadyAdded: isAlreadyAdded)
        }.ensure {
            self.removeActivityIndicator()
        }.catch { error in
            
            let alert = self.createErrorAlert(withMessage: error.localizedDescription)
            self.present(alert, animated: true)

            switch error {
            case let networkError as NetworkService.Error:
                let alert = self.createErrorAlert(withMessage: networkError.localizedDescription)
                self.present(alert, animated: true)
            case let networkDictionaryError as NetworkDictionaryService.Error:
                let alert = self.createErrorAlert(withMessage: networkDictionaryError.localizedDescription)
                self.present(alert, animated: true)
            default:
                let alert = self.createErrorAlert(withMessage: "Undefined error")
                self.present(alert, animated: true)
            }
        }
    }
    
    func createErrorAlert(withMessage message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            
        return alert
    }
    
    func configureUI() {
        configureSearchButton()
        configureEmptySearchImage()
        configureSearchTextField()
    }
    
    func configureSearchTextField() {
        searchTextField.delegate = self
    }
    
    func configureSearchButton() {
        searchButton.layer.cornerRadius = 10
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        searchButtonContainerView.insertSubview(blurEffectView, at: 0)
                
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: searchButtonContainerView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: searchButtonContainerView.leadingAnchor),
            blurEffectView.heightAnchor.constraint(equalTo: searchButtonContainerView.heightAnchor),
            blurEffectView.widthAnchor.constraint(equalTo: searchButtonContainerView.widthAnchor)
        ])
        blurEffectView.layer.cornerRadius = 10
        blurEffectView.clipsToBounds = true
    }
    
    func configureEmptySearchImage() {
        guard UIScreen.main.bounds.height < 736 else { return }

        let ratio = (UIScreen.main.bounds.height / 736) - 0.25
        emptySearchImageHeightConstraint.constant *= ratio
    }
    
    func addSearchWordView(_ word: Word) {
        guard let wordView = Bundle.main.loadNibNamed(SearchedWordView.identifier, owner: self, options: nil)?.first as? SearchedWordView else {
            print("search word view is not loaded")
            return
        }
        
        let isAlreadyAdded = storageService.contains(word: word.word)
        wordView.vmodel = SearchedWordView.ViewModel(searchedWord: word, isAlreadyAdded: isAlreadyAdded)
        wordView.delegate = self
        self.searchedWordView = wordView
        self.contentView.addSubview(wordView)
                
        wordView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wordView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            wordView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            wordView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            wordView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}

// MARK: -
// MARK: TextField delegate
extension SearchVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.last == " " && string == " " {
            return false
        }
        return true
    }
}

// MARK: -
// MARK: SearchedWordView delegate
extension SearchVC: SearchedWordViewDelegate {
    func seacrhedWordViewDidTapRemoveButton(_ view: SearchedWordView) {
        guard let word = searchedWord else { return }

        do {
            try storageService.removeWord(word)
        } catch let error as DiskStorage.Error {
            let alert = self.createErrorAlert(withMessage: error.rawValue)
            present(alert, animated: true)
        } catch let error as CoreDataStorage.Error {
            let alert = self.createErrorAlert(withMessage: error.rawValue)
            present(alert, animated: true)
        } catch {
            let alert = self.createErrorAlert(withMessage: "Something went wrong")
            present(alert, animated: true)
        }
    }
    
    func seacrhedWordViewDidTapSaveButton(_ view: SearchedWordView) {
        guard let word = searchedWord else { return }
        
        do {
            try storageService.addWord(word)
        } catch let error as DiskStorage.Error {
            let alert = self.createErrorAlert(withMessage: error.rawValue)
            present(alert, animated: true)
        } catch let error as CoreDataStorage.Error {
            let alert = self.createErrorAlert(withMessage: error.rawValue)
            present(alert, animated: true)
        } catch {
            let alert = self.createErrorAlert(withMessage: "Something went wrong")
            present(alert, animated: true)
        }
    }
}

// MARK: -
// MARK: StorageService observer
extension SearchVC: StorageServiceObserver {
    func storageServiceDidRemoveWord(_ word: Word?, at indexPath: IndexPath?) { }
    func storageServiceDidUpdate(with newWords: [Word]) { }
    func storageServiceDidUpdate(word: Word) { }
}
