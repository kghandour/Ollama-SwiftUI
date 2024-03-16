//
//  ManageModelsController.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import Foundation
import SwiftUI

@MainActor
class ManageModelsController: ObservableObject{
    @Published var tags: tagsParent?
    @Published var errorModel: ErrorModel = ErrorModel(showError: false, errorTitle: "", errorMessage: "")
    @Published var modelName: String = ""
    @Published var toDuplicate: String = ""
    @Published var newName: String = ""
    @Published var showProgress: Bool = false
    @Published var showingErrorPopover: Bool = false
    @Published var totalSize: Double = 0
    @Published var completedSoFar: Double = 0
    
    let ollamaController = OllamaController()
    
    func getTags(){
        Task{
            do{
                self.tags = try await ollamaController.getLocalModels()
                self.errorModel.showError = false
                if(self.tags != nil){
                    if(self.tags!.models.count > 0){
                        self.toDuplicate = self.tags!.models[0].name
                    }else{
                        self.toDuplicate = ""
                        self.errorModel = noModelsError(error: nil)
                    }
                }else{
                    self.toDuplicate = ""
                    self.errorModel = noModelsError(error: nil)
                }
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
    
    func downloadModel(){
        Task{
            do{
                showProgress = true
                
                let endpoint = ollamaController.apiAddress + "/api/pull"
                
                guard let url = URL(string: endpoint) else {
                    throw NetError.invalidURL(error: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = "{\"name\":\"\(modelName)\"}".data(using: String.Encoding.utf8)!

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
                getTags()
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
                try await ollamaController.deleteModel(name: name)
                getTags()
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
    
    func duplicateModel(){
        Task{
            do{
                try await ollamaController.copyModel(toDuplicate: self.toDuplicate, newName: self.newName)
                getTags()
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

