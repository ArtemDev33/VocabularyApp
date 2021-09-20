//
//  NetworkImageService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 15.07.2021.
//

import Foundation
import PromiseKit
import Alamofire
import AlamofireImage

// MARK: -
// MARK: Error
extension NetworkImageService {
    enum Error: LocalizedError {

        case invalidRequest
        case unknown(reason: String?)
        case afError(reason: String)
        case badResponse

        var errorDescription: String? {
            switch self {
            case .unknown(let reason): return "Something went wrong. \(reason ?? "")"
            case .invalidRequest:      return "Invalid request"
            case .afError(let reason): return reason
            case .badResponse:         return "Bad response"
            }
        }
    }
}

// MARK: -
// MARK: Class declaration
final class NetworkImageService {
    
    static let shared = NetworkImageService()
    
    private init() { }
    
    func image(forURL urlString: String) -> Promise<UIImage> {
        Promise { seal in
            AF.request(urlString).validate().responseImage { response in
                guard case let .failure(error) = response.result else {
                    
                    guard let image = response.value else {
                        seal.reject(Error.badResponse)
                        return
                    }
                    
                    seal.fulfill(image)
                    return
                }
                
                seal.reject(Error.afError(reason: error.localizedDescription))
            }
            .resume()
        }
    }
}
