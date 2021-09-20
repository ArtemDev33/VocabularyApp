
//
//  SearchedWordView.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 30.04.2021.
//

import UIKit

protocol SearchedWordViewDelegate: AnyObject {
    func seacrhedWordViewDidTapSaveButton(_ view: SearchedWordView)
    func seacrhedWordViewDidTapRemoveButton(_ view: SearchedWordView)
}

extension SearchedWordView {
    struct ViewModel {
        let word: String
        let definition: String
        let example: String
        var isAlreadyAdded: Bool
        
        init(searchedWord: Word, isAlreadyAdded: Bool) {
            word = searchedWord.word
            
            let partOfSpeech = searchedWord.meanings.first?.partOfSpeech ?? ""
            let definition = searchedWord.meanings.first?.definitions.first?.definition ?? ""
            self.definition = partOfSpeech.isEmpty ? definition : "(\(partOfSpeech)) \(definition)"
            
            let example = searchedWord.meanings.first?.definitions.first?.example ?? ""
            self.example = example.isEmpty ? "" : "(\(example))"
            
            self.isAlreadyAdded = isAlreadyAdded
        }
    }
}

final class SearchedWordView: UIView {
    @IBOutlet private weak var wordLabel: UILabel!
    @IBOutlet private weak var definitionLabel: UILabel!
    @IBOutlet private weak var exampleLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    
    static let identifier: String = "SearchedWordView"
    static func nib() -> UINib {
        UINib(nibName: "SearchedWordView", bundle: nil)
    }
    
    var vmodel: ViewModel? {
        didSet {
            guard let vm = vmodel else { return }
            self.configure(with: vm)
        }
    }
    
    weak var delegate: SearchedWordViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        delegate?.seacrhedWordViewDidTapSaveButton(self)
        vmodel?.isAlreadyAdded = true
    }
    
    @IBAction func didTapremoveButton(_ sender: UIButton) {
        delegate?.seacrhedWordViewDidTapRemoveButton(self)
        vmodel?.isAlreadyAdded = false
    }
}

// MARK: -
// MARK: Private
private extension SearchedWordView {
    func configureUI() {
        configureRadiuses()
    }
    
    func configureRadiuses() {
        containerView.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        removeButton.layer.cornerRadius = 10
    }
    
    func configure(with vmodel: ViewModel) {
        wordLabel.text = vmodel.word.capitalized
        definitionLabel.text = vmodel.definition
        exampleLabel.text = vmodel.example
        
        removeButton.isHidden = !vmodel.isAlreadyAdded
        saveButton.isHidden = vmodel.isAlreadyAdded
    }
}
