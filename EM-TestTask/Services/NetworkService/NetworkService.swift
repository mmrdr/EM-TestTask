//
//  NetworkService.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let baseURL: String = "https://dummyjson.com/todos"
    
    func request<T: Decodable, K: Codable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: K? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        
        guard let request = prepareRequest(
            endpoint: endpoint,
            method: method,
            queryItems: queryItems,
            body: body,
            headers: headers
        ) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.unknown(message: "No HTTP response")))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                switch httpResponse.statusCode {
                case 400:
                    if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                        completion(.failure(NetworkError(message: str) ?? .unknown(message: "UnknownError")))
                    } else {
                        completion(.failure(NetworkError.unknown(message: "UnknownError")))
                    }
                case 403: completion(.failure(NetworkError.forbidden))
                case 404: completion(.failure(NetworkError.notFound))
                case 500...599: completion(.failure(NetworkError.internalServerError))
                default: completion(.failure(NetworkError.unknown(message: "UnknownError")))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let iso = ISO8601DateFormatter()
                iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // важно для .649
                decoder.dateDecodingStrategy = .custom { d in
                    let c = try d.singleValueContainer()
                    let s = try c.decode(String.self)
                    if let date = iso.date(from: s) {
                        return date
                    }
                    // fallback: без долей секунды
                    let isoNoFrac = ISO8601DateFormatter()
                    isoNoFrac.formatOptions = [.withInternetDateTime]
                    if let date = isoNoFrac.date(from: s) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid ISO8601 date: \(s)")
                }
                let decoded = try decoder.decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    private func prepareRequest<K: Codable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: K?,
        headers: [String: String]?
    ) -> URLRequest? {
        var urlComponents = URLComponents(string: baseURL + endpoint)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return nil
            }
        }
        return request
    }
}
