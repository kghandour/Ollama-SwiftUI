//
//  ManageModelsView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import SwiftUI

struct ManageModelsView: View {
    @State private var tags: tagsParent?
    @State private var errorModel: ErrorModel = ErrorModel(showError: false, errorTitle: "", errorMessage: "")
    @State private var modelName: String = ""
    @State private var toDuplicate: String = ""
    @State private var newName: String = ""
    @State private var showProgress: Bool = false
    @State private var showingErrorPopover: Bool = false
    @State private var totalSize: Double = 0
    @State private var completedSoFar: Double = 0
    
    @AppStorage("host") private var host = "http://127.0.0.1"
    @AppStorage("port") private var port = "11434"

    var body: some View {
        VStack(alignment: .leading){
            Text("Local Models:")
                .font(.headline)
            if(tags?.models.count == 0){
                HStack{
                    Label("Error", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                    Text("No models downloaded locally. Add a model by typing the name in the field at the bottom of the page.")
                }
            }
            List(tags?.models ?? [], id: \.self){ model in
                HStack{
                    VStack(alignment: .leading){
                        Text(model.name)
                        Text("\(model.size / 1024 / 1024 / 1024, specifier: "%.3f") GB")
                    }
                    Spacer()
                    
                    Button{
                        removeModel(name: model.name)
                    }label: {
                        Image(systemName: "trash")
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }
            
            HStack{
                Text("Duplicate Model:")
                        .font(.headline)
                Picker("Duplicate Model:", selection: $toDuplicate) {
                    ForEach(tags?.models ?? [], id: \.self) {model in
                        Text(model.name).tag(model.name)
                    }
                }
                TextField("New Name", text: $newName)
                    .textFieldStyle(.roundedBorder)
                Button{
                    duplicateModel(source: toDuplicate, destination: newName)
                }label: {
                    Image(systemName: "doc.on.doc")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            Spacer()
            HStack{
                Text("Add Model:")
                    .font(.headline)
                TextField("Add model:", text: $modelName)
                    .textFieldStyle(.roundedBorder)
                Button{
                    downloadModel(name: modelName)
                }label: {
                    Image(systemName: "arrowshape.down.fill")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            if(showProgress){
                HStack{
                    Text("Downloading \(modelName)")
                    ProgressView(value: completedSoFar, total: totalSize)
                    Text("\(Int(completedSoFar / 1024 / 1024 ))/ \(Int(totalSize / 1024 / 1024)) MB")
                }
            }
            VStack(alignment: .leading){
                Text("To find the model names to download, checkout: https://ollama.ai/library")
                    .textSelection(.enabled)
                Text("A good starting model is llama2. Simply write the model name in the field above")
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 500, minHeight: 600, idealHeight: 800)
        .task {
            getTags()
        }
        .toolbar{
            HStack{
                if(errorModel.showError){
                        Button {
                            self.showingErrorPopover.toggle()
                        } label: {
                            Label("Error", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                        }
                        .popover(isPresented: self.$showingErrorPopover) {
                            VStack(alignment: .leading) {
                                Text(self.errorModel.errorTitle)
                                    .font(.title2)
                                    .textSelection(.enabled)
                                Text(self.errorModel.errorMessage)
                                    .textSelection(.enabled)
                            }
                            .padding()
                        }
                }else{
                    Text("Server:")
                    Label("Connected", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                }
                Button{
                    getTags()
                }label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
        }
    }
    func getTags(){
        Task{
            do{
                tags = try await getLocalModels(host: "\(host):\(port)")
                errorModel.showError = false
                if(self.tags != nil){
                    if(self.tags!.models.count > 0){
                        toDuplicate = self.tags!.models[0].name
                    }else{
                        toDuplicate = ""
                        errorModel = noModelsError(error: nil)
                    }
                }else{
                    toDuplicate = ""
                    errorModel = noModelsError(error: nil)
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
                try await deleteModel(host: "\(host):\(port)", name: name)
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
    
    func duplicateModel(source: String, destination: String){
        Task{
            do{
                try await copyModel(host: "\(host):\(port)", source: source, destination: destination)
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

#Preview {
    ManageModelsView()
}
