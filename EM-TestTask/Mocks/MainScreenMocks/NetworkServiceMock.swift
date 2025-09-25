//
//  NetworkServiceMock.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

final class NetworkServiceMock: NetworkServiceProtocol {
    struct AnyResult {
        let box: Any
    }
    var queuedResults: [AnyResult] = []
    private(set) var calls: [HTTPCall] = []

    func enqueueResult<T>(_ result: Result<T, Error>) {
        queuedResults.append(.init(box: result))
    }

    func request<T: Decodable, K: Codable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: K?,
        headers: [String : String]?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        calls.append(.request(
            endpoint: endpoint,
            method: method,
            queryItems: queryItems,
            bodyType: body.map { String(describing: type(of: $0)) },
            headers: headers
        ))
        guard !queuedResults.isEmpty else {
            completion(.failure(NSError(domain: "NetworkServiceMock", code: -1)))
            return
        }
        let any = queuedResults.removeFirst().box
        if let casted = any as? Result<T, Error> {
            completion(casted)
        } else {
            completion(.failure(NSError(domain: "NetworkServiceMockTypeMismatch", code: -2)))
        }
    }
}

enum HTTPCall {
    case request(endpoint: String, method: HTTPMethod, queryItems: [URLQueryItem]?, bodyType: String?, headers: [String: String]?)
}
