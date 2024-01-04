//
//  ChatViewModel.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var prompt: PromptModel = .init(prompt: "", model: "", system: "")
    @Published var sentPrompt: [String] = []
    @Published var receivedResponse: [String] = []
    @Published var tags: tagsParent?
    @Published var disabledButton: Bool = true
    @Published var disabledEditor: Bool = false
    @Published var errorModel: ErrorModel = .init(showError: false, errorTitle: "", errorMessage: "")
    
    @AppStorage("host") var host = DefaultSettings.host
    @AppStorage("port") var port = DefaultSettings.port
    
    private let chatService: ChatService
    
    init(chatService: ChatService) {
        self.chatService = chatService
    }

    func getTags() {
        Task {
            do {
                self.disabledButton = false
                self.disabledEditor = false
                self.errorModel.showError = false
                self.tags = try await self.chatService.getLocalModels(host: "\(self.host):\(self.port)")
                self.prompt.model = self.tags?.models[0].name ?? ""
            } catch let NetError.invalidURL(error) {
                errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                errorModel = invalidTagsDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                errorModel = unreachableError(error: error)
            } catch {
                self.errorModel = genericError(error: error)
            }
        }
    }
    
    func resetChat() {
        self.sentPrompt = []
        self.receivedResponse = []
    }
    
    func send() {
        Task {
            do {
                self.errorModel.showError = false
                self.disabledEditor = true
                
                self.sentPrompt.append(self.prompt.prompt)
                
                var chatHistory = ChatModel(model: self.prompt.model, messages: [])
                
                for i in 0 ..< self.sentPrompt.count {
                    chatHistory.messages.append(ChatMessage(role: "user", content: self.sentPrompt[i]))
                    if i < self.receivedResponse.count {
                        chatHistory.messages.append(ChatMessage(role: "assistant", content: self.receivedResponse[i]))
                    }
                }
                
                self.receivedResponse.append("")
                
                print("Sending request")
                let endpoint = "\(host):\(port)" + "/api/chat"
                
                guard let url = URL(string: endpoint) else {
                    throw NetError.invalidURL(error: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                request.httpBody = try encoder.encode(chatHistory)
                
                let data: URLSession.AsyncBytes
                let response: URLResponse
                
                do {
                    (data, response) = try await URLSession.shared.bytes(for: request)
                } catch {
                    throw NetError.unreachable(error: error)
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetError.invalidResponse(error: nil)
                }
                
                for try await line in data.lines {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let data = line.data(using: .utf8)!
                    let decoded = try decoder.decode(ResponseModel.self, from: data)
                    self.receivedResponse[self.receivedResponse.count - 1].append(decoded.message.content)
                }
                self.disabledEditor = false
                self.prompt.prompt = ""
            } catch let NetError.invalidURL(error) {
                errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                errorModel = invalidDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                errorModel = unreachableError(error: error)
            } catch {
                self.errorModel = genericError(error: error)
            }
        }
    }

}
