//
//  NetworkManager.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 16/07/26.
//

import SwiftUI


protocol NetworkManagerProtocol {
    func get(path: String) async throws -> Data?
    func post(path: String, req: Data) async throws -> Data?
}


enum NetworkError: LocalizedError {
    case invalidUrl
    case failedToEncodeCredentials
    case invalidResponse
    case httpError(code: Int, body: String?)
    
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "server url is not valid"
        case .failedToEncodeCredentials:
            return "failed to encrypt the request"
        case .invalidResponse:
            return "invalid response from server"
        case .httpError(let code, let body):
            var message = ""
            switch code {
            case 401, 403:
                message =  "invalid credentials, status_code: \(code), \(body ?? "")"
            case 404:
                message = "resource not found"
            case 400:
                message = "bad request"
            default:
                message = "server error status_code: \(code), \(body ?? "")"
            }
            return message
        }
    }
}


class NetworkManager: NetworkManagerProtocol {
    private let host: String
    private let username = Config.stringValue(forKey: "SECRET_USERNAME")
    private let password = Config.stringValue(forKey: "SECRET_PASSWORD")
    
    init(host: String) {
        self.host = host
    }
    
    func get(path: String) async throws -> Data? {
        guard let url = URL(string: "\(host)\(path)") else {
            throw NetworkError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(
                code: httpResponse.statusCode, body: String(data: data, encoding: .utf8)
            )
        }
        
        return data
    }
    
    func post(path: String, req: Data) async throws -> Data? {
        guard let url = URL(string: "\(host)\(path)") else {
            throw NetworkError.invalidUrl
        }
        let credentials = "\(username):\(password)"

        guard let credsData = credentials.data(using: .utf8) else {
            throw NetworkError.failedToEncodeCredentials
        }
        let base64Credentials = credsData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = req
                
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
                    
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(
                    code: httpResponse.statusCode, body: String(data: data, encoding: .utf8)
                )
            }
            return data

        } catch {
            throw error
        }
    }
}
