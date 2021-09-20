//
//  RequestBuilder.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 05.05.2021.
//

import Foundation
import Alamofire

struct RequestParameters: Codable {
    let firstParam: Int
    let secondParam: String
}

final class RequestBuilder {
    private let sessionManager: Session
    private let baseURL = "https://api.dictionaryapi.dev/api/v2/entries/"
    
    init(sessionManager: Alamofire.Session) {
        self.sessionManager = sessionManager
    }
    
    func wordRequest(word: String, languageCode: String = "en_US/") -> DataRequest? {
        let endpoint = "\(baseURL)\(languageCode)\(word)"
        guard let encodedEndPoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
        }

        return request(for: encodedEndPoint, httpMethod: .get)
    }
    
    func imageRequest(urlString: String) -> DataRequest? {
        request(for: urlString, httpMethod: .get)
    }
}

// MARK: -
// MARK: Private
private extension RequestBuilder {
    func request(for endpoint: String,
                 parameters: RequestParameters? = nil,
                 httpMethod: HTTPMethod) -> DataRequest? {

        let encoder: ParameterEncoder
        switch httpMethod {
        case .post, .patch:
            encoder = JSONParameterEncoder.prettyPrinted
        default:
            let encodedForm = URLEncodedFormEncoder(spaceEncoding: .percentEscaped)
            encoder = URLEncodedFormParameterEncoder(encoder: encodedForm, destination: .queryString)
        }

        let dataRequest = sessionManager.request(
            endpoint,
            method: httpMethod,
            parameters: parameters,
            encoder: encoder)
        
        return dataRequest
    }
}
