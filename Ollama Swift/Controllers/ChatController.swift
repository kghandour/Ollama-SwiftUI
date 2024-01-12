//
//  ChatController.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation


func sendPrompt(host:String, prompt: PromptModel, timeoutRequest: String, timeoutResource: String) async throws -> [ResponseModel]{
    print("Sending request")
    let endpoint = host + "/api/generate"
    
    guard let url = URL(string: endpoint) else {
        throw NetError.invalidURL(error: nil)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    request.httpBody = try encoder.encode(prompt)
    
    let data: Data
    let response: URLResponse
    
    do{
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = Double(timeoutRequest) ?? 60
        sessionConfig.timeoutIntervalForResource = Double(timeoutResource) ?? 604800
        (data, response) = try await URLSession(configuration: sessionConfig).data(for: request)
    }catch{
        throw NetError.unreachable(error: error)
    }
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw NetError.invalidResponse(error: nil)
    }
    do {
        let json = try JSONParser.JSONObjectsWithData(data: data)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode([ResponseModel].self, from: json)
        return decoded
    } catch {
        print(error)
        throw NetError.invalidData(error: error)
    }
}

func getLocalModels(host: String, timeoutRequest: String, timeoutResource: String) async throws -> tagsParent{
    let endpoint = host + "/api/tags"
    
    guard let url = URL(string: endpoint) else {
        throw NetError.invalidURL(error: nil)
    }
            
    let data: Data
    let response: URLResponse
    
    do{
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = Double(timeoutRequest) ?? 60
        sessionConfig.timeoutIntervalForResource = Double(timeoutResource) ?? 604800
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
