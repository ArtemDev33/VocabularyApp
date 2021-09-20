//
//  MainUIRouter+ThemesVCDelegate.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 10.08.2021.
//

import Foundation
import PromiseKit
import NVActivityIndicatorView

extension MainUIRouter: ThemesVCDelegate {
    
    func didSelectTheme(_ controller: ThemesVC, title: String) -> Bool {
        iapManager.containsTheme(title: title)
    }
    
    func didTapBuyThemeButton(_ controller: ThemesVC, productKey: String, themeTitle: String) {
        guard iapManager.canMakePayments() else {
            controller.showAlert(title: "Error", message: IAPManager.Err.paymentsNotAllowed.message)
            return
        }
        
        guard let product = iapManager.product(for: productKey) else {
            controller.showAlert(title: "Error", message: IAPManager.Err.noProductsFound.message)
            return
        }
        
        controller.startAnimating()
        firstly {
            iapManager.buy(product: product)
        }.done { result in
            controller.processBoughtTheme()
            self.iapManager.addNewBoughtTheme(title: themeTitle)
        }.ensure {
            controller.stopAnimating()
        }.catch { error in
            if let error = error as? IAPManager.Err {
                controller.showAlert(title: "Error", message: error.message)
            } else {
                controller.showAlert(title: "Error", message: error.uidescription)
            }
        }
    }
}
