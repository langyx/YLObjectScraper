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
    var publisher: AnyPublisher<T, Error>? = nil
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
        
        publisher =  URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private mutating func fetch(completion: @escaping ((T) -> ())) {
        publisher?.sink(receiveCompletion: { _ in }, receiveValue: completion)
            .store(in: &cancellabes)
    }
    
    mutating func call(url: URL,
              parameters: [String: String]? = nil,
              header: [String: String]? = nil,
              completion: @escaping ((T) -> ())
    ) {
        prepare(url: url, parameters: parameters, header: header)
        fetch(completion: completion)
    }
}
