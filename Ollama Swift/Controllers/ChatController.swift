//
//  ChatController.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation
import SwiftUI

@MainActor
class ChatController: ObservableObject{
    @Published var prompt: PromptModel = .init(prompt: "", model: "", system: "")
    @Published var sentPrompt: [String] = []
    @Published var receivedResponse: [String] = []
    @Published var tags: tagsParent?
    @Published var disabledButton: Bool = true
    @Published var disabledEditor: Bool = false
    @Published var showingErrorPopover: Bool = false
    @Published var errorModel: ErrorModel = .init(showError: false, errorTitle: "", errorMessage: "")
    
    @AppStorage("host") private var host = "http://127.0.0.1"
    @AppStorage("port") private var port = "11434"
    @AppStorage("timeoutRequest") private var timeoutRequest = "60"
    @AppStorage("timeoutResource") private var timeoutResource = "604800"
    
    func getTags() {
        Task {
            do {
                self.disabledButton = false
                self.disabledEditor = false
                self.errorModel.showError = false
                self.tags = try await getLocalModels()
                if(self.tags != nil){
                    if(self.tags!.models.count > 0){
                        self.prompt.model = self.tags!.models[0].name
                    }else{
                        self.prompt.model = ""
                        self.errorModel = noModelsError(error: nil)
                    }
                }else{
                    self.prompt.model = ""
                    self.errorModel = noModelsError(error: nil)
                }
            } catch let NetError.invalidURL(error) {
                self.errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                self.errorModel = invalidTagsDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                self.errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                self.errorModel = unreachableError(error: error)
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
                let endpoint = "\(self.host):\(self.port)" + "/api/chat"
                
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
                    let sessionConfig = URLSessionConfiguration.default
                    sessionConfig.timeoutIntervalForRequest = Double(self.timeoutRequest) ?? 60
                    sessionConfig.timeoutIntervalForResource = Double(self.timeoutResource) ?? 604800
                    (data, response) = try await URLSession(configuration: sessionConfig).bytes(for: request)
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
    
    func getLocalModels() async throws -> tagsParent{
        let endpoint = "\(self.host):\(self.port)/api/tags"

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
}

