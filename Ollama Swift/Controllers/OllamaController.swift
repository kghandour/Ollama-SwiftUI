//
//  OllamaController.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 16.03.24.
//

import Foundation
import SwiftUI

@MainActor
class OllamaController: ObservableObject{
    @AppStorage("host") var host = DefaultValues.host
    @AppStorage("port") var port = DefaultValues.port
    @AppStorage("timeoutRequest") var timeoutRequest = DefaultValues.timeoutRequest
    @AppStorage("timeoutResource") var timeoutResource = DefaultValues.timeoutResource
    var apiAddress = ""
    init() {
        apiAddress = "\(self.host):\(self.port)"
    }
    
    func getLocalModels() async throws -> tagsParent{
        let endpoint =  apiAddress + "/api/tags"

        guard let url = URL(string: endpoint) else {
            throw NetError.invalidURL(error: nil)
        }
                
        let data: Data
        let response: URLResponse
        
        do{
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = Double(self.timeoutRequest) ?? 60
            sessionConfig.timeoutIntervalForResource = Double(self.timeoutResource) ?? 604800
            (data, response) = try await URLSession(configuration: sessionConfig).data(from: url)
        }catch{
            throw NetError.unreachable(error: error)
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetError.invalidResponse(error: nil)
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(tagsParent.self, from: data)
            return decoded
        } catch {
            throw NetError.invalidData(error: error)
        }
    }
    
    func deleteModel(name: String) async throws{
        let endpoint = apiAddress + "/api/delete"
        
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

    func copyModel(toDuplicate:String, newName:String) async throws {
        print("Sending request")
        let endpoint = apiAddress + "/api/copy"
        
        guard let url = URL(string: endpoint) else {
            throw NetError.invalidURL(error: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = "{\"source\":\"\(toDuplicate)\", \"destination\":\"\(newName)\"}".data(using: String.Encoding.utf8)!
        
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
