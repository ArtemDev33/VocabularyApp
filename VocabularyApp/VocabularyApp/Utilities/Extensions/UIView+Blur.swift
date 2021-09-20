//
//  UIView+Blur.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 21.05.2021.
//

import UIKit

extension UIView {
    
    static func addBluredBackground(for customView: UIView) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        customView.insertSubview(blurEffectView, at: 0)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: customView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            blurEffectView.heightAnchor.constraint(equalTo: customView.heightAnchor),
            blurEffectView.widthAnchor.constraint(equalTo: customView.widthAnchor)
        ])
        blurEffectView.layer.cornerRadius = 10
        blurEffectView.clipsToBounds = true
    }
}
