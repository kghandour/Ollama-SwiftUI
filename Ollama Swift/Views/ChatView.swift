//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI

struct ChatView: View {
    @State private var prompt: promptModel = promptModel(prompt: "hello", model: "mistral:latest", systemPrompt: "")
    @State private var responses: [responseModel]?
    @State private var backFromResponse = "Response is displayed here"
    @State private var tags: tagsParent?
    
    var body: some View {
        VStack{
            Text(backFromResponse)
            
            Spacer()
            
            Form {
                Section{
                    Picker("Select Model:", selection: $prompt.model) {
                        ForEach(tags?.models ?? [], id: \.self) {model in
                            Text(model.name).tag(model.name)
                        }
                    }
                    TextField("System prompt:", text: $prompt.systemPrompt, axis: .vertical)
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
                self.backFromResponse = ""
                self.responses = try? await sendPrompt(prompt: prompt)
                for res in self.responses! {
                    self.backFromResponse.append(res.response ?? "")
                }
            }
        }
    }
}
