//
//  IAPManager.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 10.08.2021.
//

import Foundation
import StoreKit
import PromiseKit

// MARK: -
// MARK: Errors
extension IAPManager {
    
    enum Err: VCBError {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
        case paymentsNotAllowed
        
        var message: String {
            switch self {
            case .noProductIDsFound:    return "No In-App Purchase product identifiers were found."
            case .noProductsFound:      return "No In-App Purchases were found."
            case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
            case .paymentWasCancelled:  return "In-App Purchase process was cancelled."
            case .paymentsNotAllowed:   return "In-App Purchases are not allowed on this device."
            }
        }
    }
}

// MARK: -
// MARK: Class declaration
final class IAPManager: NSObject {
    
    static let buyThemeKey = "newTheme"

    private var onReceiveProductsResolver: Resolver<[SKProduct]>?
    private var onBuyProductResolver: Resolver<Bool>?
    
    private var products: [SKProduct] = []
    
    private var boughtThemeTitles: [String] = [] {
        didSet {
            saveThemeTitles()
        }
    }
    
    override init() {
        super.init()
        self.restoreBoughtThemes()
    }
    
    func fetchProducts() -> Promise<[SKProduct]> {
        
        Promise<[SKProduct]> { seal in
            guard let productIDs = productIDs() else {
                seal.reject(Err.noProductIDsFound)
                return
            }
            
            self.onReceiveProductsResolver = seal
            
            let request = SKProductsRequest(productIdentifiers: Set(productIDs))
            request.delegate = self
            request.start()
        }
    }
    
    func buy(product: SKProduct) -> Promise<Bool> {
        
        Promise<Bool> { seal in
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            onBuyProductResolver = seal
        }
    }
    
    func product(for key: String) -> SKProduct? {
        products.first(where: { $0.productIdentifier.contains(key) })
    }
    
    func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
     
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func addNewBoughtTheme(title: String) {
        boughtThemeTitles.isEmpty ? boughtThemeTitles = [title] : boughtThemeTitles.append(title)
    }
    
    func containsTheme(title: String) -> Bool {
        boughtThemeTitles.contains(title)
    }
}

// MARK: -
// MARK: Private
private extension IAPManager {
    
    func productIDs() -> [String]? {
        
        if let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let productIDs = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] {
            
            return productIDs
        }
        return nil
    }
    
    func priceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func saveThemeTitles() {
        guard !boughtThemeTitles.isEmpty else { return }
        
        UserDefaults.standard.set(boughtThemeTitles, forKey: "boughtThemes")
    }
    
    func restoreBoughtThemes() {
        guard let array = UserDefaults.standard.stringArray(forKey: "boughtThemes") else { return }
        boughtThemeTitles = array
    }
}

// MARK: -
// MARK: SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products
        
        if !products.isEmpty {
            self.products = products
            onReceiveProductsResolver?.fulfill(products)
        } else {
            onReceiveProductsResolver?.reject(Err.noProductsFound)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsResolver?.reject(Err.productRequestFailed)
    }
}

// MARK: -
// MARK: SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                onBuyProductResolver?.fulfill(true)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                break
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductResolver?.reject(error)
                    } else {
                        onBuyProductResolver?.reject(Err.paymentWasCancelled)
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }
}
