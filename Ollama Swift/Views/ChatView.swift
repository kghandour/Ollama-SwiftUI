//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI

struct ChatView: View {
    let fontSize: CGFloat = 15
    
    @State private var prompt: promptModel = promptModel(prompt: "", model: "", system: "")
    @State private var sentPrompt: [String] = []
    @State private var receivedResponse: [String] = []
    @State private var tags: tagsParent?
    @State private var disabledButton: Bool = true
    @State private var disabledEditor: Bool = false
    @State private var errorModel: ErrorModel = ErrorModel(showError: false, errorTitle: "", errorMessage: "")
    @FocusState private var promptFieldIsFocused: Bool
    @AppStorage("host") private var host = "http://127.0.0.1"
    @AppStorage("port") private var port = "11434"
    
    var body: some View {
        VStack{
            HStack{
                if(errorModel.showError){
                    VStack (alignment: .leading) {
                        Text(errorModel.errorTitle)
                            .bold()
                            .textSelection(.enabled)
                        Text(errorModel.errorMessage)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .background(.red)
                    .cornerRadius(10)
                    .foregroundStyle(.white)
                }else{
                    HStack{
                        Text("Server Status: ")
                        Text("Online")
                            .foregroundStyle(.green)
                    }
                }
                Spacer()
                Button{
                    getTags()
                }label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 20, height: 30, alignment: .center)
                }
            }
            ScrollView{
                Text("This is the start of your chat")
                    .foregroundStyle(.secondary)
                
                ForEach(Array(sentPrompt.enumerated()), id: \.offset) { idx, sent in
                    ChatBubble(direction: .right) {
                        Text(.init(sent))
                            .font(.system(size: fontSize))
                            .padding()
                            .textSelection(.enabled)
                            .foregroundStyle(.white)
                            .background(Color.green)
                    }
                    ChatBubble(direction: .left) {
                        Text(.init(receivedResponse.indices.contains(idx) ? receivedResponse[idx] : "..."))
                            .font(.system(size: fontSize))
                            .padding()
                            .textSelection(.enabled)
                            .foregroundStyle(.white)
                            .background(Color.blue)
                    }
                }
                
            }
            .defaultScrollAnchor(.bottom)
            
            Spacer()
            HStack{
                Picker("Model:", selection: $prompt.model) {
                    ForEach(tags?.models ?? [], id: \.self) {model in
                        Text(model.name).tag(model.name)
                    }
                }
                NavigationLink{
                    ManageModelsView()
                } label: {
                    Text("Manage Models")
                        .frame(width: 100, height: 30, alignment: .center)
                }
            }
            HStack{
                TextField(" Enter prompt...", text: self.disabledEditor ? .constant(prompt.prompt) : $prompt.prompt, axis: .vertical)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.secondary, lineWidth: 2)
                    )
                    .font(.system(size: fontSize))
                    .lineLimit(5)
                    .onChange(of: prompt.prompt){
                        if(prompt.prompt.count > 0){
                            self.disabledButton = false
                        }else{
                            self.disabledButton = true
                        }
                    }
                    .focused($promptFieldIsFocused)
                    .disabled(self.disabledEditor)
                    .onSubmit {
                        !self.disabledButton ? send() : nil
                    }
                
                Button{
                    send()
                }label:{
                    Image(systemName: "paperplane")
                        .frame(width: 20, height: 30, alignment: .center)
                }
                .disabled(self.disabledButton)
                
                Button{
                    resetChat()
                }label: {
                    Image(systemName: "trash")
                        .frame(width: 20, height: 30, alignment: .center)
                }
            }
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .task {
            getTags()
        }
    }
    
    func getTags(){
        Task{
            do{
                disabledButton = false
                disabledEditor = false
                errorModel.showError = false
                tags = try await getLocalModels(host: "\(host):\(port)")
                prompt.model = tags?.models[0].name ?? ""
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
    
    func resetChat(){
        self.sentPrompt = []
        self.receivedResponse = []
    }
    
    func send() {
        Task {
            do{
                self.errorModel.showError = false
                self.disabledEditor = true
                self.sentPrompt.append(prompt.prompt)
                self.receivedResponse.append("")
                print("Sending request")
                let endpoint = "\(host):\(port)" + "/api/generate"
                
                guard let url = URL(string: endpoint) else {
                    throw NetError.invalidURL(error: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                request.httpBody = try encoder.encode(prompt)
                
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
                    let decoded = try decoder.decode(responseModel.self, from: data)
                    self.receivedResponse[self.receivedResponse.count-1].append(decoded.response ?? "")
                }
                self.disabledEditor = false
                self.prompt.prompt = ""
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
    ChatView()
}
