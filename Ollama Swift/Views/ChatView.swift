//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI

struct ChatView: View {
    @State private var prompt: promptModel = promptModel(prompt: "", model: "mistral:latest", system: "")
//    @State private var responses: [responseModel]?
    @State private var sentPrompt: [String] = []
    @State private var receivedResponse: [String] = []
    @State private var tags: tagsParent?
    @State private var disabledButton: Bool = true
    @State private var disabledEditor: Bool = false
    
    var body: some View {
        VStack{
            ScrollView{
                ForEach(Array(sentPrompt.enumerated()), id: \.offset) { idx, sent in
                    ChatBubble(direction: .right) {
                        Text(.init(sent))
                            .padding()
                            .textSelection(.enabled)
                            .foregroundColor(.white)
                            .background(Color.green)
                    }
                    if(receivedResponse.indices.contains(idx)){
                        ChatBubble(direction: .left) {
                            Text(.init(receivedResponse[idx]))
                                .padding()
                                .textSelection(.enabled)
                                .foregroundColor(.white)
                                .background(Color.blue)
                        }
                    }else{
                        ChatBubble(direction: .left) {
                            Text(.init("..."))
                                .padding()
                                .textSelection(.enabled)
                                .foregroundColor(.white)
                                .background(Color.blue)
                        }
                    }
                }
                
            }
            .defaultScrollAnchor(.bottom)
            
            Spacer()
            Picker("Select Model:", selection: $prompt.model) {
                ForEach(tags?.models ?? [], id: \.self) {model in
                    Text(model.name).tag(model.name)
                }
            }
            Form{
                HStack{
                    TextEditor(text: self.disabledEditor ? .constant(prompt.prompt) : $prompt.prompt)
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .multilineTextAlignment(.leading)
                        .textEditorStyle(AutomaticTextEditorStyle())
                        .onChange(of: prompt.prompt){
                            if(prompt.prompt.count > 0){
                                self.disabledButton = false
                            }else{
                                self.disabledButton = true
                            }
                        }
                        .disabled(self.disabledEditor)
                        
                    VStack{
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
                            Image(systemName: "arrow.clockwise")
                                .frame(width: 20, height: 30, alignment: .trailing)
                        }
                    }
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
    
    func resetChat(){
        self.sentPrompt = []
        self.receivedResponse = []
    }
    
    func send() {
        Task {
            do{
                self.disabledEditor = true
                self.sentPrompt.append(prompt.prompt)
                var backFromResponse = ""
                let responses = try? await sendPrompt(prompt: prompt)
                for res in responses! {
                    backFromResponse.append(res.response ?? "")
                }
                self.disabledEditor = false
                self.prompt.prompt = ""
                self.receivedResponse.append(backFromResponse)
            }
        }
    }
}
