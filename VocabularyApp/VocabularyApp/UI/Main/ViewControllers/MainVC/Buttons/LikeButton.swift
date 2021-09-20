//
//  LikeButton.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 11.05.2021.
//

import UIKit

final class LikeButton: UIButton {
    private let unlikedImage = UIImage(named: "heart")!
    private let likedImage = UIImage(named: "heart-full")!
    
    var isLiked = false

//    override public init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setBackgroundImage(unlikedImage, for: .normal)
//    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func flipLikedState() {
        animate()
        isLiked = !isLiked
    }
}

// MARK: -
// MARK: Private
private extension LikeButton {
    func animate() {
        UIView.animate(withDuration: 0.1, animations: {
            let newImage = self.isLiked ? self.unlikedImage : self.likedImage
            self.transform = self.transform.scaledBy(x: 0.8, y: 0.8)
            self.setBackgroundImage(newImage, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        })
    }
}
