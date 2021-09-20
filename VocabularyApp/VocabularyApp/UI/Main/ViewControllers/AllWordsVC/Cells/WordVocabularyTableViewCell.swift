//
//  WordVocabularyTableViewCell.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 11.05.2021.
//

import UIKit

extension WordVocabularyTableViewCell {
    enum State {
        case normal
        case extended
    }

    struct ViewModel {
        let word: String
        let definition: String
        let example: String
        var state: State
        
        mutating func toggleState() {
            state = (state == .extended) ? .normal : .extended
        }
        
        init(searchedWord: Word) {
            word = searchedWord.word
            
            let partOfSpeech = searchedWord.meanings.first?.partOfSpeech ?? ""
            let definition = searchedWord.meanings.first?.definitions.first?.definition ?? ""
            self.definition = partOfSpeech.isEmpty ? definition : ("(\(partOfSpeech)) " + definition)
            
            let example = searchedWord.meanings.first?.definitions.first?.example ?? ""
            self.example = example.isEmpty ? "" : "(\(example))"
            
            state = .normal
        }
        
        static func vmodels(from words: [Word]) -> [ViewModel] {
            words.map { ViewModel(searchedWord: $0) }
        }
    }
}

final class WordVocabularyTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var definitionLabel: UILabel!
    @IBOutlet private weak var exampleLabel: UILabel!

    static let identifier: String = "WordVocabularyTableViewCell"
    static func nib() -> UINib {
        UINib(nibName: "WordVocabularyTableViewCell", bundle: nil)
    }
    
    var vmodel: ViewModel? {
        didSet {
            guard let vm = vmodel else { return }
            self.configure(with: vm)
        }
    }
}

// MARK: -
// MARK: Private
private extension WordVocabularyTableViewCell {
    func configure(with vmodel: ViewModel) {
        titleLabel.text = vmodel.word.uppercased()
        definitionLabel.text = vmodel.definition
        exampleLabel.text = vmodel.example
        
        switch vmodel.state {
        case .normal: hideLabels()
        case .extended: showLabels()
        }
    }
    
    func hideLabels() {
        definitionLabel.isHidden = true
        exampleLabel.isHidden = true
    }
    
    func showLabels() {
        definitionLabel.isHidden = false
        exampleLabel.isHidden = false
    }
}
