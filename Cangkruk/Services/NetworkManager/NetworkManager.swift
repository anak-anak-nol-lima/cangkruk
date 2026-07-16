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
    case invalidResponse
    case httpError(code: Int)
}


class NetworkManager: NetworkManagerProtocol {
    @AppStorage("token") var token: String = ""
    private var host: String
    
    init(host: String) {
        self.host = host
    }
    
    func get(path: String) async throws -> Data? {
        guard let url = URL(string: "\(host)\(path)") else {
            throw NetworkError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
    
    func post(path: String, req: Data) async throws -> Data? {
        guard let url = URL(string: "\(host)\(path)") else {
            throw NetworkError.invalidUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = req
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            return data

        } catch {
            print(error)
            throw error
        }
    }
}
