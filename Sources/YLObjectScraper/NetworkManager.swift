//
//  NetworkManager.swift
//  
//
//  Created by Yannis Lang on 29/10/2021.
//

import Foundation
import Combine

struct NetworkManager<T: Codable> {
    var cancellabes = [AnyCancellable]()
    var publisher: AnyPublisher<T, NetworkFailureReason>? = nil
    var header = [String: String]()
}

extension NetworkManager {
    private mutating func prepare(url: URL,
                 parameters: [String: String]? = nil,
                 header: [String: String]? = nil,
                 method: String = "GET")
    {
        
        var urlBuilder = URLComponents(string: url.absoluteString)
        urlBuilder?.queryItems = parameters?.map({ (key, value) in
            URLQueryItem(name: key, value: value)
        })
        
        guard let url = urlBuilder?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        let headers = self.header.merging(header ?? [:]) { $1 }
        headers.forEach({ (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        })
        
        publisher = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error in
                switch error {
                case is Swift.DecodingError:
                    return .decodingFailed
                case let urlError as URLError:
                    return .sessionFailed(error: urlError)
                default:
                    return .other(error)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private mutating func fetch(completion: @escaping ((T) -> ()),
                                errorCompletion: ((NetworkFailureReason)->())? = nil) {
        publisher?
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: completion)
            .store(in: &cancellabes)
    }
    
    mutating func call(url: URL,
              parameters: [String: String]? = nil,
              header: [String: String]? = nil,
              completion: @escaping ((T) -> ()),
              errorCompletion: ((NetworkFailureReason)->())? = nil
    ) {
        prepare(url: url, parameters: parameters, header: header)
        fetch(completion: completion, errorCompletion: errorCompletion)
    }
}

public enum NetworkFailureReason : Error {
      case sessionFailed(error: URLError)
      case decodingFailed
      case other(Error)
  }
