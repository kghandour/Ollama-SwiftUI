//
//  ManageModelService.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import Foundation

protocol ManageModelServiceProtocol {
    func deleteModel(host:String, name: String) async throws
    func copyModel(host:String, source: String, destination: String) async throws
}

class ManageModelService: ManageModelServiceProtocol {
    func deleteModel(host:String, name: String) async throws {
        print("Sending request")
        let endpoint = host + "/api/delete"
        
        guard let url = URL(string: endpoint) else {
            throw NetError.invalidURL(error: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = "{\"name\":\"\(name)\"}".data(using: String.Encoding.utf8)!
        
        let response: URLResponse
        
        do{
            (_, response) = try await URLSession.shared.data(for: request)
        }catch{
            throw NetError.unreachable(error: error)
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetError.invalidResponse(error: nil)
        }
    }

    func copyModel(host:String, source: String, destination: String) async throws {
        print("Sending request")
        let endpoint = host + "/api/copy"
        
        guard let url = URL(string: endpoint) else {
            throw NetError.invalidURL(error: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = "{\"source\":\"\(source)\", \"destination\":\"\(destination)\"}".data(using: String.Encoding.utf8)!
        
        let response: URLResponse
        
        do{
            (_, response) = try await URLSession.shared.data(for: request)
        }catch{
            throw NetError.unreachable(error: error)
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetError.invalidResponse(error: nil)
        }
    }
}
