//
//  ActivityIndicator.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 05.05.2021.
//

import UIKit
import NVActivityIndicatorView

private var activityIndicatorView: UIActivityIndicatorView?
private var nvActivityIndicatorView: NVActivityIndicatorView?

extension UIViewController {
    func showActivityIndicator() {
        if #available(iOS 13, *) {
            activityIndicatorView = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        }
        
        guard let aiView = activityIndicatorView else { return }
        
        aiView.center = view.center
        aiView.startAnimating()
        self.view.addSubview(aiView)
    }
    
    func removeActivityIndicator() {
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
    }
}

extension UIViewController {
    func startAnimating() {
        
        view.isUserInteractionEnabled = false
        self.isModalInPresentation = true
                
        let frame = CGRect(x: 0, y: 0, width: view.frame.width / 3, height: view.frame.height / 3)
        let activityView = NVActivityIndicatorView(frame: frame)
        activityView.center = view.center
        activityView.startAnimating()
        view.addSubview(activityView)
        
        nvActivityIndicatorView = activityView
    }
    
    func stopAnimating() {
        view.isUserInteractionEnabled = true
        self.isModalInPresentation = false
        nvActivityIndicatorView?.stopAnimating()
        nvActivityIndicatorView?.removeFromSuperview()
        nvActivityIndicatorView = nil
    }
}
