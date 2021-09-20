//
//  NetworkService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 07.05.2021.
//

import Foundation
import Alamofire
import PromiseKit

// MARK: -
// MARK: Error
extension NetworkService {
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
// MARK: Class
final class NetworkService {
    
    let requestBuilder: RequestBuilder

    init(requestBuilder: RequestBuilder) {
        self.requestBuilder = requestBuilder
    }
    
    func execute(request: DataRequest?) -> Promise<Data> {
        let queue = DispatchQueue(label: "network.request", qos: .background, attributes: .concurrent)
        
        return Promise { seal in
            guard let dataRequest = request else {
                seal.reject(Error.invalidRequest)
                return
            }
            dataRequest.validate().response(queue: queue) { response in
                guard case let .failure(error) = response.result else {
                    guard let optionalData = response.value,
                          let data = optionalData
                    else {
                        seal.reject(Error.badResponse)
                        return
                    }
                    seal.fulfill(data)
                    return
                }
                seal.reject(Error.afError(reason: error.localizedDescription))
            }
            .resume()
        }
    }
}
