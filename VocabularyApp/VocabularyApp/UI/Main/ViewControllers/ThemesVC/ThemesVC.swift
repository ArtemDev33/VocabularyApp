//
//  ThemesVC.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.05.2021.
//

import UIKit
import PromiseKit
import SnapKit

// MARK: -
// MARK: Delegate
protocol ThemesVCDelegate: AnyObject {
    func didTapBuyThemeButton(_ controller: ThemesVC, productKey: String, themeTitle: String)
    func didSelectTheme(_ controller: ThemesVC, title: String) -> Bool
}

// MARK: -
// MARK: Class declaration
final class ThemesVC: UIViewController {
    let mysuperkey = "adfjkskldsjflkjwfkljwafkljadksjkadjsfklfas"
    
    typealias Item = (model: Theme, vmodel: ThemeCollectionViewCell.ViewModel)
    
    private var themesCollectionView: UICollectionView!
    private var purchaseThemeView: PurchaseThemeView?
    private var purchaseThemeBackgroundView: UIView?
    private var themes: [Item] = []
    
    private var themeToBuy: Item?
    private var themeToBuyImage: UIImage?
    
    var themeService: ThemeService!
    weak var delegate: ThemesVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchThemes()
        
        themeService.subscribeForUpdates(observer: self)
    }
    
    deinit {
        themeService.unsubscribeFromUpdates(observer: self)
    }
    
    func processBoughtTheme() {
        guard let theme = themeToBuy,
              let image = themeToBuyImage else { return }
        
        if case .url = theme.model.type {
            themeService.didSelectNewTheme(theme.model, image: image)
        } else {
            themeService.didSelectNewTheme(theme.model)
        }
       
        themeToBuy = nil
        themeToBuyImage = nil
        animatePurchaseThemeViewDisappearing()
    }
}

// MARK: -
// MARK: Private
private extension ThemesVC {
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar()
        createCollectionView()
    }
    
    func createCollectionView() {
        let layout = UICollectionViewFlowLayout()
        themesCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 17, bottom: 10, right: 17)
        layout.minimumInteritemSpacing = 12.0
        layout.minimumLineSpacing = 12.0
        let width = themesCollectionView.bounds.width / 3 - 20
        layout.itemSize = CGSize(width: width, height: width * 1.35)
        
        themesCollectionView.backgroundColor = .clear
        themesCollectionView.register(ThemeCollectionViewCell.nib(), forCellWithReuseIdentifier: ThemeCollectionViewCell.identifier)
        
        view.addSubview(themesCollectionView)
        
        themesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            themesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            themesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            themesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            themesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        themesCollectionView.delegate = self
        themesCollectionView.dataSource = self
    }
    
    func createPurchaseThemeView(image: UIImage, themeTitle: String) {
        purchaseThemeView = Bundle.main.loadNibNamed(PurchaseThemeView.identifier, owner: self, options: nil)?.first as? PurchaseThemeView
        purchaseThemeBackgroundView = UIView(frame: view.frame)
        
        guard let purchaseView = purchaseThemeView,
              let bgView = purchaseThemeBackgroundView else { return }
        
        self.isModalInPresentation = true
        
        bgView.backgroundColor = .black.withAlphaComponent(0.5)
        bgView.center = view.center
        view.addSubview(bgView)
        
        purchaseView.image = image
        purchaseView.themeTitle = themeTitle
        purchaseView.delegate = self
        purchaseView.alpha = 0.0
        purchaseView.scale(by: CGPoint(x: 0.1, y: 0.1))
        
        bgView.addSubview(purchaseView)
        purchaseView.translatesAutoresizingMaskIntoConstraints = false
        purchaseView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(40)
            maker.height.equalTo(280)
            maker.centerY.equalToSuperview()
        }
    }
    
    func animatePurchaseThemeViewAppearing() {
        guard let purchaseView = purchaseThemeView else { return }
            
        UIView.animate(withDuration: 0.2) {
            purchaseView.alpha = 1.0
            purchaseView.scale(by: CGPoint(x: 10, y: 10))
        }
    }
    
    func animatePurchaseThemeViewDisappearing() {
        guard let purchaseView = purchaseThemeView else { return }
            
        UIView.animate(withDuration: 0.2) {
            purchaseView.alpha = 0.0
            purchaseView.scale(by: CGPoint(x: 0.1, y: 0.1))
        } completion: { _ in
            self.isModalInPresentation = false
            self.purchaseThemeView?.removeFromSuperview()
            self.purchaseThemeView = nil
            self.purchaseThemeBackgroundView?.removeFromSuperview()
            self.purchaseThemeBackgroundView = nil
        }
    }
    
    func configureNavigationBar() {
        title = "Themes"
        navigationController?.navigationBar.prefersLargeTitles = true
        let doneButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDoneButton(_:)))
        doneButton.tintColor = .black
        navigationItem.leftBarButtonItem = doneButton
    }
    
    @objc func didTapDoneButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchThemes() {
        guard !themeService.didFetchAllThemes else {
            mapIntoItems(themes: themeService.allThemes)
            return
        }
        
        self.showActivityIndicator()
        firstly {
            themeService.fetchAllThemes()
        }.done(on: DispatchQueue.main) { [weak self] themes in
            guard let self = self else { return }
            self.removeActivityIndicator()
            self.reload(with: themes)
        }.ensure {
            self.removeActivityIndicator()
        }.catch { error in
            print(error.localizedDescription)
        }
    }
    
    func reload(with themes: [Theme]) {
        mapIntoItems(themes: themes)
        themesCollectionView.reloadData()
    }
    
    func mapIntoItems(themes: [Theme]) {
        let viewModels = ThemeCollectionViewCell.ViewModel.vmodels(from: themes)
        let items = zip(themes, viewModels).map { Item($0, $1) }
        self.themes = items
    }
}

// MARK: -
// MARK: CollectionView datasource
extension ThemesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemeCollectionViewCell.identifier,
                                                            for: indexPath) as? ThemeCollectionViewCell else { fatalError() }
        var vmodel = themes[indexPath.row].vmodel
        vmodel.isSelected = (themeService.chosenTheme?.title == vmodel.title)
        cell.vmodel = vmodel
    
        return cell
    }
}

// MARK: -
// MARK: CollectionView delegate
extension ThemesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! ThemeCollectionViewCell
        
        if let result = delegate?.didSelectTheme(self, title: theme.model.title), result {
            guard case .url = theme.model.type else {
                themeService.didSelectNewTheme(theme.model)
                return
            }
            let image = cell.themeImage()
            themeService.didSelectNewTheme(theme.model, image: image)
            
        } else {
            if let image = cell.themeImage() {
                themeToBuy = theme
                themeToBuyImage = image
                createPurchaseThemeView(image: image, themeTitle: theme.model.title)
                animatePurchaseThemeViewAppearing()
                return
            }
            
            themeService.didSelectNewTheme(theme.model)
        }
    }
}

extension ThemesVC: ThemeServiceObserver {
    func themeServiceDidUpdate(with newTheme: Theme) {
        for cell in themesCollectionView.visibleCells {
            let desiredCell = cell as! ThemeCollectionViewCell
            if desiredCell.vmodel?.title == newTheme.title {
                desiredCell.vmodel?.isSelected = true
            } else {
                desiredCell.vmodel?.isSelected = false
            }
        }
    }
}

// MARK: -
// MARK: PurchaseThemeViewDelegate
extension ThemesVC: PurchaseThemeViewDelegate {
    
    func didTapCloseButton(_ view: PurchaseThemeView) {
        animatePurchaseThemeViewDisappearing()
    }
    
    func didTapBuyButton(_ view: PurchaseThemeView, productKey: String) {
        guard let title = themeToBuy?.model.title else { return }
        delegate?.didTapBuyThemeButton(self, productKey: productKey, themeTitle: title)
    }
}
