//
//  ThemeCollectionViewCell.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 20.05.2021.
//

import UIKit
import AlamofireImage

// MARK: -
// MARK: ViewModel
extension ThemeCollectionViewCell {
    struct ViewModel {
        let title: String
        let font: String
        let type: ThemeType
        var isSelected: Bool
        
        init(theme: Theme, isSelected: Bool) {
            self.title = theme.title
            self.font = theme.font
            self.isSelected = isSelected
            
            switch theme.type {
            case .color(let color):
                type = .color(color.color!)
            case .local(let icon):
                type = .local(icon.image, icon.thumbnail)
            case .url(let url):
                type = .url(url)
            }
        }
        
        static func vmodels(from themes: [Theme]) -> [ViewModel] {
            themes.map { ViewModel(theme: $0, isSelected: false) }
        }
    }
    
    enum ThemeType {
        case color(UIColor?)
        case local(UIImage?, UIImage?)
        case url(String)
    }
}

// MARK: -
// MARK: Class declaration
final class ThemeCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var themeImageView: UIImageView!
    @IBOutlet private weak var fontExampleLabel: UILabel!
    @IBOutlet private weak var isChosenThemeView: UIView!
    
    static let identifier: String = "ThemeCollectionViewCell"
    static func nib() -> UINib {
        UINib(nibName: "ThemeCollectionViewCell", bundle: nil)
    }
        
    var vmodel: ViewModel? {
        didSet {
            guard let vm = vmodel else { return }
            self.configure(with: vm)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hideChosenStatus()
    }
    
    func themeImage() -> UIImage? {
        themeImageView.image
    }
}

// MARK: -
// MARK: Private
private extension ThemeCollectionViewCell {
    
    func configureUI() {
        contentView.layer.cornerRadius = 5
        themeImageView.contentMode = .scaleAspectFill
        themeImageView.clipsToBounds = true
        themeImageView.layer.cornerRadius = 4
        UIView.addBluredBackground(for: isChosenThemeView)
        isChosenThemeView.isHidden = true
    }
    
    func configure(with vmodel: ViewModel) {
        switch vmodel.type {
        case .color(let color):
            themeImageView.isHidden = true
            contentView.backgroundColor = color
        case .local(_, let thumbnailImage):
            themeImageView.isHidden = false
            themeImageView.image = thumbnailImage
        case .url(let url):
            themeImageView.af.setImage(withURL: URL(string: url)!,
                                       placeholderImage: nil,
                                       filter: nil,
                                       imageTransition: .crossDissolve(0.5),
                                       runImageTransitionIfCached: false)
        }
        
        if let customFont = UIFont(name: vmodel.font, size: 35) {
            fontExampleLabel.font = customFont
        }
        
        if vmodel.isSelected {
            showChosenStatus()
        } else {
            hideChosenStatus()
        }
    }
    
    func showChosenStatus() {
        isChosenThemeView.isHidden = false
    }
    
    func hideChosenStatus() {
        isChosenThemeView.isHidden = true
    }
}
