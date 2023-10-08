//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI

struct ChatView: View {
    @State private var prompt: promptModel = promptModel(prompt: "hello", model: "mistral", systemPrompt: "")
    @State private var responses: [responseModel]?
    @State private var backFromResponse = "Response is displayed here"

    var body: some View {
        VStack{
            Text(backFromResponse)
            
            Spacer()
            
            Form {
                TextField("Model name", text: $prompt.model)
                TextField("System Prompt", text: $prompt.systemPrompt)
                TextField("Prompt", text: $prompt.prompt)
            }
            
            Button("Submit", action: send)
        }
        .padding()
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
