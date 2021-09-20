//
//  PurchaseThemeView.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 10.08.2021.
//
import UIKit

// MARK: -
// MARK: Delegate
protocol PurchaseThemeViewDelegate: AnyObject {
    func didTapCloseButton(_ view: PurchaseThemeView)
    func didTapBuyButton(_ view: PurchaseThemeView, productKey: String)
}

// MARK: -
// MARK: Class declaration
final class PurchaseThemeView: UIView {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var buyButton: UIButton!
    
    static let identifier: String = "PurchaseThemeView"
    
    var themeTitle: String?
    
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            imageView.image = image
        }
    }
    
    weak var delegate: PurchaseThemeViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func didTapClosebutton(_ sender: UIButton) {
        delegate?.didTapCloseButton(self)
    }
    
    @IBAction func didTapBuyButton(_ sender: UIButton) {
        guard let key = themeTitle else { return }
        delegate?.didTapBuyButton(self, productKey: key)
    }
}

// MARK: -
// MARK: Private
private extension PurchaseThemeView {
    
    func setupUI() {
        containerView.layer.cornerRadius = 17
        buyButton.layer.cornerRadius = 15
        titleLabel.text = "Sunset"
        priceLabel.text = "1.99 $"
    }
}
