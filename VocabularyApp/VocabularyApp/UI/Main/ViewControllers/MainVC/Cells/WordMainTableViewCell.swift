//
//  WordMainTableViewCell.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 29.04.2021.
//

import UIKit

protocol WordMainTableViewCellDelegate: AnyObject {
    func wordCelldidTapLikeButton(_ cell: WordMainTableViewCell, _ word: String)
}

extension WordMainTableViewCell {
    struct ViewModel {
        let word: String
        let definition: String
        let example: String
        let isFavourite: Bool
        
        init(searchedWord: Word) {
            word = searchedWord.word
            
            let partOfSpeech = searchedWord.meanings.first?.partOfSpeech ?? ""
            let definition = searchedWord.meanings.first?.definitions.first?.definition ?? ""
            self.definition = partOfSpeech.isEmpty ? definition : ("(\(partOfSpeech)) " + definition)
            
            let example = searchedWord.meanings.first?.definitions.first?.example ?? ""
            self.example = example.isEmpty ? "" : "(\(example))"
            
            isFavourite = searchedWord.isFavourite
        }
        
        static func vmodels(from words: [Word]) -> [ViewModel] {
            words.map { ViewModel(searchedWord: $0) }
        }
    }
}

final class WordMainTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var definitionLabel: UILabel!
    @IBOutlet private weak var exampleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
        
    var vmodel: ViewModel? {
        didSet {
            guard let vm = vmodel else { return }
            self.configure(with: vm)
        }
    }
    
    private var likeButton: LikeButton!
    
    weak var delegate: WordMainTableViewCellDelegate?
    
    static let identifier: String = "WordMainTableViewCell"
    static func nib() -> UINib {
        UINib(nibName: "WordMainTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addLikeButton()
    }
    
    func setFont(named: String?) {
        guard let fontTitle = named else {
            titleLabel.font = UIFont.systemFont(ofSize: 28)
            definitionLabel.font = UIFont.systemFont(ofSize: 22)
            exampleLabel.font = UIFont.systemFont(ofSize: 22)
            return
        }
        
        guard let titleFont = UIFont(name: "\(fontTitle)-Bold", size: 28),
              let definitionFont = UIFont(name: "\(fontTitle)-Medium", size: 22),
              let exampleFont = UIFont(name: "\(fontTitle)-Medium", size: 22) else {
            return
        }
        
        titleLabel.font = titleFont
        definitionLabel.font = definitionFont
        exampleLabel.font = exampleFont
    }
}

// MARK: -
// MARK: Private
private extension WordMainTableViewCell {
    func configure(with vmodel: ViewModel) {
        titleLabel.text = vmodel.word.uppercased()
        definitionLabel.text = vmodel.definition
        exampleLabel.text = vmodel.example
        if vmodel.isFavourite {
            self.likeButton?.setBackgroundImage(UIImage(named: "heart-full")!, for: .normal)
        } else {
            self.likeButton?.setBackgroundImage(UIImage(named: "heart")!, for: .normal)
        }
    }
    
    func addLikeButton() {
        let likeButton = LikeButton()
        
        self.contentView.addSubview(likeButton)
                
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 35),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45),
            likeButton.widthAnchor.constraint(equalToConstant: 49),
            likeButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton(sender:)), for: .touchUpInside)
        likeButton.tintColor = .white
        
        self.likeButton = likeButton
    }
    
    @objc func didTapLikeButton(sender: LikeButton) {
        guard let vmodel = vmodel else { return }
        
        delegate?.wordCelldidTapLikeButton(self, vmodel.word)
        sender.isLiked = vmodel.isFavourite
        sender.flipLikedState()
        if !vmodel.isFavourite {
            performLikeAnimation()
        }
    }
    
    func performLikeAnimation() {
        let currentWindow: UIWindow = UIApplication.shared.windows.first!
        let image = UIImage(named: "heart-full")!
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 120, height: 100)
        imageView.tintColor = .white
        currentWindow.addSubview(imageView)
        imageView.center = currentWindow.center
        imageView.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            imageView.alpha = 1
            imageView.transform = self.transform.scaledBy(x: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                imageView.transform = CGAffineTransform.identity
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    imageView.image = UIImage(named: "heart")!
                    imageView.transform = self.transform.scaledBy(x: 1.2, y: 1.2)
                    imageView.alpha = 0
                } completion: { _ in
                    imageView.removeFromSuperview()
                }
            }
        }
    }
}
