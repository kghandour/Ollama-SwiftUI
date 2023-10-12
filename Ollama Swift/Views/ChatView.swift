//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI
import AlertToast

struct ChatView: View {
    let fontSize: CGFloat = 15
    
    @State private var prompt: promptModel = promptModel(prompt: "", model: "mistral:latest", system: "")
    @State private var sentPrompt: [String] = []
    @State private var receivedResponse: [String] = []
    @State private var tags: tagsParent?
    @State private var disabledButton: Bool = true
    @State private var disabledEditor: Bool = false
    @State private var errorModel: ErrorModel = ErrorModel(showError: false, errorTitle: "", errorMessage: "")
    @FocusState private var promptFieldIsFocused: Bool
    
    
    var body: some View {
        VStack{
            if(errorModel.showError){
                VStack{
                    Text(errorModel.errorTitle)
                        .bold()
                    Text(errorModel.errorMessage)
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .padding(5)
                .background(.red)
                .cornerRadius(10)
            }else{
                HStack{
                    Text("Server Status: ")
                    Text("Online")
                        .foregroundStyle(.green)
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
                Button("Refresh", action: getTags)
                Button("Add", action: addModel)
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
                        .frame(width: 20, height: 30, alignment: .trailing)
                }
                .disabled(self.disabledButton)
                
                Button{
                    resetChat()
                }label: {
                    Image(systemName: "trash")
                        .frame(width: 20, height: 30, alignment: .trailing)
                }
            }
        }
        .padding()
//        .toast(isPresenting: $showToast){
//            AlertToast(type: .error(.red), title: "Hello")
//        }
        .task {
            getTags()
        }
     }
    
    func addModel(){
        
    }
    
    func getTags(){
        Task{
            do{
                disabledButton = false
                disabledEditor = false
                errorModel.showError = false
                tags = try await getLocalModels()
            } catch NetError.invalidURL{
                errorModel.showError = true
                errorModel.errorTitle = "Ollama is unreachable!"
                errorModel.errorMessage = "Are you sure Ollama is installed?\n You need to download it from https://ollama.ai/"
            } catch NetError.invalidData{
                errorModel.showError = true
                errorModel.errorTitle = "Invalid Data received!"
                errorModel.errorMessage = "Looks like there is a problem retrieving the data."
            } catch NetError.invalidResponse{
                errorModel.showError = true
                errorModel.errorTitle = "Error! Receiving an invalid response"
                errorModel.errorMessage = "Looks like you are receiving a response other than 200!"
            } catch NetError.unreachable {
                errorModel.showError = true
                errorModel.errorTitle = "Server is unreachable"
                errorModel.errorMessage = "Try to open ollama and continue"
            } catch {
                errorModel.showError = true
                errorModel.errorTitle = "Uknown error"
                errorModel.errorMessage = "Unknown error shown"
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
                var backFromResponse = ""
                let responses = try await sendPrompt(prompt: prompt)
                for res in (responses) {
                    backFromResponse.append(res.response ?? "")
                }
                self.disabledEditor = false
                self.prompt.prompt = ""
                self.receivedResponse.append(backFromResponse)
            } catch NetError.invalidURL{
                errorModel.showError = true
                errorModel.errorTitle = "Ollama is unreachable!"
                errorModel.errorMessage = "Are you sure Ollama is installed?\n You need to download it from https://ollama.ai/"
            } catch NetError.invalidData{
                errorModel.showError = true
                errorModel.errorTitle = "Invalid Data received!"
                errorModel.errorMessage = "Looks like there is a problem retrieving the data."
            } catch NetError.invalidResponse{
                errorModel.showError = true
                errorModel.errorTitle = "Error! Receiving an invalid response"
                errorModel.errorMessage = "Looks like you are receiving a response other than 200!"
            } catch NetError.unreachable {
                errorModel.showError = true
                errorModel.errorTitle = "Server is unreachable"
                errorModel.errorMessage = "Try to open ollama and continue"
            } catch {
                errorModel.showError = true
                errorModel.errorTitle = "Uknown error"
                errorModel.errorMessage = "Unknown error shown"
            }
        }
    }
}
