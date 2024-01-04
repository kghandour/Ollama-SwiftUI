//
//  NetworkManager.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation

struct NetworkManager {
    static func performRequest<T: Decodable>(to endpoint: String, with data: Data? = nil, expecting: T.Type) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NetError.invalidURL(error: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = data != nil ? "POST" : "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetError.invalidResponse(error: nil)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: responseData)
        default:
            print(httpResponse.statusCode)
            throw NetError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
