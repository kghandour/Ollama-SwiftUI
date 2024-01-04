//
//  ManageModelsViewModel.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ManageModelsViewModel: ObservableObject {
    @Published var tags: tagsParent?
    @Published var errorModel: ErrorModel = ErrorModel(showError: false, errorTitle: "", errorMessage: "")
    @Published var modelName: String = ""
    @Published var toDuplicate: String = ""
    @Published var newName: String = ""
    @Published var showProgress: Bool = false
    @Published var totalSize: Double = 0
    @Published var completedSoFar: Double = 0

    @AppStorage("host") var host = DefaultSettings.host
    @AppStorage("port") var port = DefaultSettings.port
    
    private let chatService: ChatService
    private let manageModelService: ManageModelService
    
    init(chatService: ChatService, manageModelService: ManageModelService) {
        self.chatService = chatService
        self.manageModelService = manageModelService
    }

    func getTags(){
        Task{
            do{
                tags = try await chatService.getLocalModels(host: "\(host):\(port)")
                errorModel.showError = false
                toDuplicate = tags?.models[0].name ?? ""
            } catch NetError.invalidURL (let error){
                errorModel = invalidURLError(error: error)
            } catch NetError.invalidData (let error){
                errorModel = invalidTagsDataError(error: error)
            } catch NetError.invalidResponse (let error){
                errorModel = invalidResponseError(error: error)
            } catch NetError.unreachable (let error){
                errorModel = unreachableError(error: error)
            } catch {
                errorModel = genericError(error: error)
            }
        }
    }

    func downloadModel(name: String){
        Task{
            do{
                showProgress = true
                
                let endpoint = "\(host):\(port)" + "/api/pull"
                
                guard let url = URL(string: endpoint) else {
                    throw NetError.invalidURL(error: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = "{\"name\":\"\(name)\"}".data(using: String.Encoding.utf8)!

                let data: URLSession.AsyncBytes
                let response: URLResponse
                                
                do{
                    (data, response) = try await URLSession.shared.bytes(for: request)
                }catch{
                    throw NetError.unreachable(error: error)
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetError.invalidResponse(error: nil)
                }
                
                for try await line in data.lines {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let data = line.data(using: .utf8)!
                    let decoded = try decoder.decode(DownloadResponseModel.self, from: data)
                    self.completedSoFar = decoded.completed ?? 0
                    self.totalSize = decoded.total ?? 100
                }
                
                showProgress = false
                tags = try await chatService.getLocalModels(host: "\(host):\(port)")
            } catch NetError.invalidURL (let error){
                errorModel = invalidURLError(error: error)
            } catch NetError.invalidData (let error){
                errorModel = invalidDataError(error: error)
            } catch NetError.invalidResponse (let error){
                errorModel = invalidResponseError(error: error)
            } catch NetError.unreachable (let error){
                errorModel = unreachableError(error: error)
            } catch {
                errorModel = genericError(error: error)
            }
        }
    }

    func removeModel(name: String){
        Task{
            do{
                try await manageModelService.deleteModel(host: "\(host):\(port)", name: name)
                tags = try await chatService.getLocalModels(host: "\(host):\(port)")
            } catch NetError.invalidURL (let error){
                errorModel = invalidURLError(error: error)
            } catch NetError.invalidData (let error){
                errorModel = invalidDataError(error: error)
            } catch NetError.invalidResponse (let error){
                errorModel = invalidResponseError(error: error)
            } catch NetError.unreachable (let error){
                errorModel = unreachableError(error: error)
            } catch {
                errorModel = genericError(error: error)
            }
        }
    }

    func duplicateModel(source: String, destination: String){
        Task{
            do{
                try await manageModelService.copyModel(host: "\(host):\(port)", source: source, destination: destination)
                tags = try await chatService.getLocalModels(host: "\(host):\(port)")
            } catch NetError.invalidURL (let error){
                errorModel = invalidURLError(error: error)
            } catch NetError.invalidData (let error){
                errorModel = invalidDataError(error: error)
            } catch NetError.invalidResponse (let error){
                errorModel = invalidResponseError(error: error)
            } catch NetError.unreachable (let error){
                errorModel = unreachableError(error: error)
            } catch {
                errorModel = genericError(error: error)
            }
        }
    }

}
