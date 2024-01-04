//
//  ChatService.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

protocol ChatServiceProtocol {
    func sendPrompt(host: String, prompt: PromptModel) async throws -> [ResponseModel]
    func getLocalModels(host: String) async throws -> TagsParent
}

class ChatService: ChatServiceProtocol {
    func sendPrompt(host: String, prompt: PromptModel) async throws -> [ResponseModel] {
        let endpoint = host + "/api/generate"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let encodedData = try encoder.encode(prompt)
        
        return try await NetworkManager.performRequest(to: endpoint, with: encodedData, expecting: [ResponseModel].self)
    }

    func getLocalModels(host: String) async throws -> TagsParent {
        let endpoint = host + "/api/tags"
        return try await NetworkManager.performRequest(to: endpoint, expecting: TagsParent.self)
    }
}
