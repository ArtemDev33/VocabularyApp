//
//  NetworkDictionaryService.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 05.05.2021.
//

import Foundation
import Alamofire
import PromiseKit

// MARK: -
// MARK: Error
extension NetworkDictionaryService {
    enum Error: LocalizedError {
        
        case dataParsingFailed

        var errorDescription: String? {
            switch self {
            case .dataParsingFailed:   return "Data parding failed"
            }
        }
    }
}

// MARK: -
// MARK: Class declaration
final class NetworkDictionaryService {
    
    let networkService: NetworkService
    let requestBuilder: RequestBuilder
    
    init(networkService: NetworkService, requestBuilder: RequestBuilder) {
        self.networkService = networkService
        self.requestBuilder = requestBuilder
    }
    
    func word(word: String) -> Promise<Word> {
        let request = requestBuilder.wordRequest(word: word)
        
        return firstly {
            networkService.execute(request: request)
        }.compactMap { data in
            guard let words = try? JSONDecoder().decode([Word].self, from: data),
                  let word = words.first else { throw Error.dataParsingFailed }
            return word
        }
    }
}
