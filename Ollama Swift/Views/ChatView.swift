//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI

struct ChatView: View {
    @State private var prompt: promptModel = promptModel(prompt: "hello", model: "mistral:latest", system: "")
    @State private var responses: [responseModel]?
    @State private var sentPrompt: [String] = []
    @State private var receivedResponse: [String] = []
    @State private var tags: tagsParent?
    
    var body: some View {
        VStack{
            ScrollViewReader { proxy in
                ScrollView{
                    ForEach(Array(sentPrompt.enumerated()), id: \.offset) { idx, sent in
                        ChatBubble(direction: .right) {
                            Text(.init(sent))
                                .padding()
                                .textSelection(.enabled)
                                .foregroundColor(.white)
                                .background(Color.blue)
                        }
                        if(receivedResponse.indices.contains(idx)){
                            ChatBubble(direction: .left) {
                                Text(.init(receivedResponse[idx]))
                                    .padding()
                                    .textSelection(.enabled)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                            }
                            .id(idx)
                        }else{
                            ChatBubble(direction: .left) {
                                Text(.init("..."))
                                    .padding()
                                    .textSelection(.enabled)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                            }
                            .id(idx)
                        }
                    }
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(.white)
                .onChange(of: receivedResponse.count) {
                    proxy.scrollTo(receivedResponse.count-1)}
            }
            
            Spacer()
            
            Form {
                Section{
                    Picker("Select Model:", selection: $prompt.model) {
                        ForEach(tags?.models ?? [], id: \.self) {model in
                            Text(model.name).tag(model.name)
                        }
                    }
                    TextField("System prompt:", text: $prompt.system, axis: .vertical)
                        .lineLimit(2...3)
                    TextField("Prompt Message:", text: $prompt.prompt, axis: .vertical)
                        .lineLimit(2...5)
                }
                .onSubmit(send)
                
                Section{
                    Button("Submit", action: send)
                }
            }
            
        }
        .padding()
        .task {
            do{
                tags = try await getLocalModels()
            } catch {
                print("Error retrieving tags")
            }
        }
     }
    
    func send() {
        Task {
            do{
                self.sentPrompt.append(prompt.prompt)
                var backFromResponse = ""
                self.responses = try? await sendPrompt(prompt: prompt)
                for res in self.responses! {
                    backFromResponse.append(res.response ?? "")
                }
                self.receivedResponse.append(backFromResponse)
            }
        }
    }
}
