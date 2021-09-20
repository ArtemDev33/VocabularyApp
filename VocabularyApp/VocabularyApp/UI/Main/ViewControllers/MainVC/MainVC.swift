//
//  MainVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 29.04.2021.
//

import UIKit
import PromiseKit

// MARK: -
// MARK: Delegate
protocol MainVCDelegate: AnyObject {
    func didLoadView(_ controller: MainVC)
    func didTapFindWordButton(_ controller: MainVC)
    func didTapMenuButton(_ controller: MainVC)
    func didTapThemesButton(_ controller: MainVC)
    func didTapProfileButton(_ controller: MainVC)
    func didReceiveNewPushWord(_ controller: MainVC, word: String)
}

// MARK: -
// MARK: Class declaration
final class MainVC: UIViewController {
    
    typealias Item = (model: Word, vmodel: WordMainTableViewCell.ViewModel)
    let initialAlertTransitionDuration = 0.3
    
    @IBOutlet private weak var wordsTableView: UITableView!
    @IBOutlet private weak var findWordButton: UIButton!
    
    @IBOutlet private weak var themeButton: UIButton!
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var menuButton: UIButton!
    
    @IBOutlet private weak var menuButtonBackgroundView: UIView!
    @IBOutlet private weak var themeButtonBackgroundView: UIView!
    @IBOutlet private weak var profileButtonBackgroundView: UIView!
    @IBOutlet private weak var findWordButtonBackgroundView: UIView!
    
    private var backgroundImageView: UIImageView?
    private var initialAlertView: InitialAlertView?
    
    static let id = "MainVC"
    
    weak var delegate: MainVCDelegate?
        
    var storageService: StorageManager!
    var networkDictionaryService: NetworkDictionaryService!
    var themeService: ThemeService!
        
    private var words: [Item] = []
    private var totalWordsCount: Int = 0
    
    private var pushNotificationsBlock: VoidBlock?
        
    let queue = DispatchQueue.global(qos: .background)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWordsTableView()
        configureButtons()
        
        storageService.subscribeForUpdates(observer: self)
        words = fetchWords()
        totalWordsCount = words.count
        
        themeService.subscribeForUpdates(observer: self)
        
        firstly {
            themeService.fetchAllLocalData()
        }.done(on: DispatchQueue.main) {
            self.configureBackgroundTheme()
        }.catch { error in
            guard let themeError = error as? ThemeService.Error else { return }
            print(themeError.rawValue)
        }
        
        delegate?.didLoadView(self)
    }
    
    deinit {
        themeService.unsubscribeFromUpdates(observer: self)
        storageService.unsubscribeFromUpdates(observer: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if pushNotificationsBlock != nil {
            pushNotificationsBlock!()
            pushNotificationsBlock = nil
        }
        
        if words.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.createInitialAlertView()
                self.animateInitialAlertAppearing()
            }
        }
    }
    
    func handlePushNotification(word: String) {
        
        let pushActionBlock: VoidBlock
        
        storageService.refreshStorage()
        words = fetchWords()
        wordsTableView.reloadData()
        if words.contains(where: { $0.model.word.lowercased() == word.lowercased() }) {
            guard let index = words.firstIndex(where: { $0.model.word.lowercased() == word.lowercased() }) else { return }
            
            pushActionBlock = { [unowned self] in
                self.wordsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
            }
        } else {
            pushActionBlock = { [unowned self] in
                self.delegate?.didReceiveNewPushWord(self, word: word)
            }
        }
        
        if isViewLoaded {
            pushActionBlock()
            pushNotificationsBlock = nil
        } else {
            pushNotificationsBlock = pushActionBlock
        }
    }
    
    @IBAction func didTapMenuButton(_ sender: UIButton) {
        delegate?.didTapMenuButton(self)
    }
    
    @IBAction func didTapFindWordButton(_ sender: UIButton) {
        delegate?.didTapFindWordButton(self)
    }
    
    @IBAction func didTapThemeButton(_ sender: UIButton) {
        delegate?.didTapThemesButton(self)
    }
    
    @IBAction func didTapProfileButton(_ sender: UIButton) {
        delegate?.didTapProfileButton(self)
    }
}

// MARK: -
// MARK: Private
private extension MainVC {
    func configureWordsTableView() {
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
        wordsTableView.isPagingEnabled = true
        wordsTableView.contentInsetAdjustmentBehavior = .never
        wordsTableView.register(WordMainTableViewCell.nib(), forCellReuseIdentifier: WordMainTableViewCell.identifier)
    }
    
    func configureButtons() {
        themeButtonBackgroundView.layer.cornerRadius = 13
        profileButtonBackgroundView.layer.cornerRadius = 13
        menuButtonBackgroundView.layer.cornerRadius = 13
        findWordButtonBackgroundView.layer.cornerRadius = 13
        
        UIView.addBluredBackground(for: themeButtonBackgroundView)
        UIView.addBluredBackground(for: profileButtonBackgroundView)
        UIView.addBluredBackground(for: menuButtonBackgroundView)
        UIView.addBluredBackground(for: findWordButtonBackgroundView)
        
        let scaledImage = UIImage(named: "Search60x60")?.scalePreservingAspectRatio(targetSize: CGSize(width: 30, height: 30))
        findWordButton.setImage(scaledImage, for: .normal)
        findWordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
    }
    
    func addBackgroundImageView(for image: UIImage) {
        if backgroundImageView == nil {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            view.insertSubview(imageView, at: 0)
        
            imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: view.topAnchor),
                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    imageView.heightAnchor.constraint(equalTo: view.heightAnchor),
                    imageView.widthAnchor.constraint(equalTo: view.widthAnchor)
                ])
        
            backgroundImageView = imageView
        } else {
            backgroundImageView?.image = image
        }
    }
    
    private func createInitialAlertView() {
        initialAlertView = Bundle.main.loadNibNamed(InitialAlertView.identifier, owner: self, options: nil)?.first as? InitialAlertView
                
        guard let alert = initialAlertView else { return }
        
        alert.alpha = 0.0
        alert.delegate = self
        
        view.addSubview(alert)
        
        alert.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alert.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alert.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            alert.heightAnchor.constraint(equalToConstant: 280),
            alert.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        ])
    }
    
    func animateInitialAlertAppearing() {
        guard let alert = initialAlertView else { return }
            
        UIView.animate(withDuration: initialAlertTransitionDuration) {
            alert.alpha = 1.0
        }
    }
        
    func animateInitialAlertDisappearing() {
        guard let alert = initialAlertView else { return }
            
        UIView.animate(withDuration: initialAlertTransitionDuration) {
            alert.alpha = 0.0
        } completion: { _ in
            self.initialAlertView = nil
        }
    }
    
    func createErrorAlert(withMessage message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            
        return alert
    }
    
    func updateWordFavouriteStatus(_ word: String) {
        guard let cell = wordsTableView.visibleCells.first as? WordMainTableViewCell,
              let updatedWord = words.first(where: { $0.vmodel.word == word }),
              cell.vmodel?.word == word  else {
            return
        }
       
        cell.vmodel = updatedWord.vmodel
    }
    
    func configureBackgroundTheme() {
        guard let theme = themeService.chosenTheme else {
            return
        }
        themeServiceDidUpdate(with: theme)
    }
    
    func fetchWords() -> [Item] {
        let words = storageService.words
        let viewModels = WordMainTableViewCell.ViewModel.vmodels(from: words)
        let items = zip(words, viewModels).map { Item($0, $1) }
        
        return items
    }
}
// MARK: -
// MARK: TableView delegate / datasource
extension MainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = wordsTableView.dequeueReusableCell(withIdentifier: WordMainTableViewCell.identifier) as? WordMainTableViewCell else {
            fatalError("Unable to dequeue a reusable cell with identifier \"\(WordMainTableViewCell.identifier)\"")
        }
        
        cell.vmodel = words[indexPath.row].vmodel
        cell.delegate = self
        cell.setFont(named: themeService.chosenTheme?.font)
        
        return cell
    }
}

extension MainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        wordsTableView.frame.height
    }
}

// MARK: -
// MARK: WordMainTableViewCell delegate
extension MainVC: WordMainTableViewCellDelegate {
    func wordCelldidTapLikeButton(_ cell: WordMainTableViewCell, _ word: String) {
        do {
            try storageService.toggleWordFavouriteStatus(of: word)
        } catch let error as DiskStorage.Error {
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
extension MainVC: StorageServiceObserver {
    func storageServiceDidRemoveWord(_ word: Word?, at indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        
        words = fetchWords()
        wordsTableView.deleteRows(at: [indexPath], with: .none)
        totalWordsCount -= 1
        
        if words.isEmpty, initialAlertView == nil {
            createInitialAlertView()
            animateInitialAlertAppearing()
        }
    }
    
    func storageServiceDidUpdate(with newWords: [Word]) {
        if initialAlertView != nil {
            initialAlertView?.removeFromSuperview()
            initialAlertView = nil
        }
        
        words = fetchWords()
        wordsTableView.insertRows(at: [IndexPath(row: words.count - 1, section: 0)], with: .none)
        totalWordsCount += 1
    }
    
    func storageServiceDidUpdate(word: Word) {
        words = fetchWords()
        updateWordFavouriteStatus(word.word)
    }
}

// MARK: -
// MARK: ThemeService observer
extension MainVC: ThemeServiceObserver {
    func themeServiceDidUpdate(with newTheme: Theme) {
        switch newTheme.type {
        case .color(let hexColor):
            view.backgroundColor = hexColor.color
            backgroundImageView?.removeFromSuperview()
            backgroundImageView = nil
        case .url:
            guard let image = themeService.chosenThemeImage else { return }
            addBackgroundImageView(for: image)
        case .local(let icon):
            guard let image = icon.image else { return }
            addBackgroundImageView(for: image)
        }
        
        guard let cell = wordsTableView.visibleCells.first as? WordMainTableViewCell else {
            return
        }
        
        cell.setFont(named: newTheme.font)
    }
}

// MARK: -
// MARK: InitialAlertView delegate
extension MainVC: InitialAlertViewDelegate {
    func didTapLetsDoItButton(_ view: InitialAlertView) {
        delegate?.didTapFindWordButton(self)
    }
    
    func didTapDeleteButton(_ view: InitialAlertView) {
        animateInitialAlertDisappearing()
    }
}
