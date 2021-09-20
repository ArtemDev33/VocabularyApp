//
//  AllWordsVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 06.05.2021.
//

import UIKit

// MARK: -
// MARK: Delegate
protocol AllWordsVCDelegate: AnyObject {
    func didTapCancelButton(controller: AllWordsVC)
}

// MARK: -
// MARK: Class
final class AllWordsVC: UIViewController {
    
    typealias Item = (model: Word, vmodel: WordVocabularyTableViewCell.ViewModel)
    
    @IBOutlet private weak var wordsTableView: UITableView!
    @IBOutlet private weak var wordsSegmentedControl: UISegmentedControl!
    
    static let id = "AllWordsVC"
    
    var networkDictionaryService: NetworkDictionaryService!
    var storageService: StorageManager!
    
    weak var delegate: AllWordsVCDelegate?
    
    private var words: [Item] = []
    private var favouriteWords: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        storageService.subscribeForUpdates(observer: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        words = fetchAllWords()
        favouriteWords = fetchFavouriteWords()
    }
    
    deinit {
        storageService.unsubscribeFromUpdates(observer: self)
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        delegate?.didTapCancelButton(controller: self)
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        wordsTableView.reloadData()
    }
}

// MARK: -
// MARK: Private
private extension AllWordsVC {
    enum SegmentContent: Int {
        case all
        case favorites
    }
    
    var currentSegmentContent: SegmentContent {
        SegmentContent(rawValue: wordsSegmentedControl.selectedSegmentIndex) ?? .all
    }
    
    func configureUI() {
        configureTableView()
    }
    
    func configureTableView() {
        wordsTableView.delegate = self
        wordsTableView.dataSource = self
        wordsTableView.register(WordVocabularyTableViewCell.nib(), forCellReuseIdentifier: WordVocabularyTableViewCell.identifier)
        wordsTableView.rowHeight = UITableView.automaticDimension
        wordsTableView.estimatedRowHeight = 100
    }
    
    func createErrorAlert(withMessage message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            
        return alert
    }
    
    func fetchFavouriteWords() -> [Item] {
        let favWords = storageService.words.filter { $0.isFavourite == true }
        let viewModels = WordVocabularyTableViewCell.ViewModel.vmodels(from: favWords)
        let items = zip(favWords, viewModels).map { Item($0, $1) }
        
        return items
    }
    
    func fetchAllWords() -> [Item] {
        let allWords = storageService.words
        let viewModels = WordVocabularyTableViewCell.ViewModel.vmodels(from: allWords)
        let items = zip(allWords, viewModels).map { Item($0, $1) }
        
        return items
    }
}

extension AllWordsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSegmentContent {
        case .all:       return words.count
        case .favorites: return favouriteWords.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentSegmentContent {
        case .all:
            guard let cell = wordsTableView.dequeueReusableCell(withIdentifier: WordVocabularyTableViewCell.identifier) as? WordVocabularyTableViewCell else {
                fatalError("Unable to dequeue a reusable cell with identifier \"\(WordVocabularyTableViewCell.identifier)\"")
            }
            
            let word = words[indexPath.row].model
            cell.vmodel = WordVocabularyTableViewCell.ViewModel(searchedWord: word)
            return cell
            
        case .favorites:
            guard let cell = wordsTableView.dequeueReusableCell(withIdentifier: WordVocabularyTableViewCell.identifier) as? WordVocabularyTableViewCell else {
                fatalError("Unable to dequeue a reusable cell with identifier \"\(WordVocabularyTableViewCell.identifier)\"")
            }

            cell.vmodel = favouriteWords[indexPath.row].vmodel
            return cell
        }
    }
}

extension AllWordsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? WordVocabularyTableViewCell else { return }
        
        tableView.performBatchUpdates({
            UIView.animate(withDuration: 0.3) {
                cell.vmodel?.toggleState()
            }
    //        tableView.beginUpdates()
    //        tableView.endUpdates()
            tableView.deselectRow(at: indexPath, animated: true)
        }, completion: { _ in })
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        switch currentSegmentContent {
        case .all:
            do {
                let word = words[indexPath.row].model
                
                try storageService.removeWord(word)
                words.removeAll(where: { $0.model == word })
                favouriteWords.removeAll(where: { $0.model == word })
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as DiskStorage.Error {
                let alert = self.createErrorAlert(withMessage: error.rawValue)
                present(alert, animated: true)
            } catch {
                let alert = self.createErrorAlert(withMessage: "Something went wrong")
                present(alert, animated: true)
            }
        case .favorites:
            do {
                let word = favouriteWords[indexPath.row].model
                
                try storageService.toggleWordFavouriteStatus(of: word.word)
                favouriteWords.removeAll(where: { $0.model == word })
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as DiskStorage.Error {
                let alert = self.createErrorAlert(withMessage: error.rawValue)
                present(alert, animated: true)
            } catch {
                let alert = self.createErrorAlert(withMessage: "Something went wrong")
                present(alert, animated: true)
            }
        }
    }
}

extension AllWordsVC: StorageServiceObserver {
    func storageServiceDidRemoveWord(_ word: Word?, at indexPath: IndexPath?) { }
    func storageServiceDidUpdate(with newWords: [Word]) { }
    func storageServiceDidUpdate(word: Word) { }
}
