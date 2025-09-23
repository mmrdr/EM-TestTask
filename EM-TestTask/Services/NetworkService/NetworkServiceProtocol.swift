//
//  NetworkServiceProtocol.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable, K: Codable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: K?,
        headers: [String: String]?,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
