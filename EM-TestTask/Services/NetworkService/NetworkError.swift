//
//  NetworkError.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case noData
    case decodingError
    case internalServerError
    case unknown(message: String?)
    case forbidden
    case notFound
    case invalidURL
    
    private static let errorMapping: [String: NetworkError] = [
        "InvalidURL": .invalidURL,
        "NoData": .noData,
        "DecodingError": .decodingError,
        "InternalServerError": .internalServerError,
        "Forbidden": .forbidden,
    ]
    
    init?(message: String) {
        if let mappedError = NetworkError.errorMapping[message.trimmingCharacters(in: .whitespacesAndNewlines)] {
            self = mappedError
        } else {
            self = .unknown(message: message)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data from server"
        case .decodingError:
            return "Error while decoding server response"
        case .internalServerError:
            return "Server error"
        case .forbidden:
            return "Access is denied"
        case .notFound:
            return "Not found"
        case .unknown(let message):
            return message ?? "Unknown error"
        }
    }
}
