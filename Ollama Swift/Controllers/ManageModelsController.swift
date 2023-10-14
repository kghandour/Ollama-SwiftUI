//
//  ManageModelsController.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import Foundation

func deleteModel(name: String) async throws -> [responseModel]{
    print("Sending request")
    let endpoint = ENDPOINT + "/api/generate"
    
    guard let url = URL(string: endpoint) else {
        throw NetError.invalidURL(error: nil)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
//    request.httpBody = try encoder.encode(/*prompt*/)
    
    let data: Data
    let response: URLResponse
    
    do{
        (data, response) = try await URLSession.shared.data(for: request)
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
        let decoded = try decoder.decode([responseModel].self, from: json)
        return decoded
    } catch {
        print(error)
        throw NetError.invalidData(error: error)
    }
}
