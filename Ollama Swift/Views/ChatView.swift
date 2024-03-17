//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import MarkdownUI
import SwiftUI

struct ChatView: View {
    @StateObject var chatController = ChatController()
    
    @FocusState private var promptFieldIsFocused: Bool
    @Namespace var bottomId
    
    var body: some View {
        VStack(spacing: 0)
        {
            ScrollViewReader{ sv in
                ScrollView {
                    Text("This is the start of your chat")
                        .foregroundStyle(.secondary)
                        .padding()
                    ForEach(Array(chatController.sentPrompt.enumerated()), id: \.offset) { idx, sent in
                        ChatBubble(direction: .right) {
                            Markdown {
                                .init(sent.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                            .markdownTextStyle{
                                ForegroundColor(Color.white)
                            }
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 8)
                            .textSelection(.enabled)
                            .background(Color.blue)
                        }
                        ChatBubble(direction: .left) {
                            Markdown {
                                .init(chatController.receivedResponse.indices.contains(idx) ?
                                      chatController.receivedResponse[idx].trimmingCharacters(in: .whitespacesAndNewlines) :
                                        "...")
                            }
                            .markdownTextStyle(\.code) {
                                FontFamilyVariant(.monospaced)
                                BackgroundColor(.white.opacity(0.25))
                            }
                            .markdownBlockStyle(\.codeBlock) { configuration in
                                configuration.label
                                    .padding()
                                    .markdownTextStyle {
                                        FontFamilyVariant(.monospaced)
                                    }
                                    .background(Color.white.opacity(0.25))
                            }
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 8)
                            .textSelection(.enabled)
                            .foregroundStyle(Color.secondary)
                            .background(Color(NSColor.secondarySystemFill))
                        }
                    }
                    Text("")
                        .id(bottomId)
                }
                .onChange(of: chatController.receivedResponse.last) { _, _ in
                    sv.scrollTo(bottomId)
                    
                }
            }
            VStack{
                VStack{
                    TextField("Enter system prompt...", text: $chatController.prompt.system, axis: .vertical)
                        .lineLimit(3)
                        .disabled(chatController.disabledEditor)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                .frame(height: chatController.expandOptions ? nil : 0)
                .clipped()
                Button{
                    withAnimation {
                        chatController.expandOptions.toggle()
                    }
                } label: {
                    if(!chatController.expandOptions){
                        Text("More Options")
                        Image(systemName: "arrow.up")
                            .frame(width: 20, height: 20, alignment: .center)
                    }else{
                        Text("Hide Options")
                        Image(systemName: "arrow.down")
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
                HStack(){
                    ZStack(alignment: .topLeading) {
                        if chatController.prompt.prompt.isEmpty {
                            Text("Enter prompt...")
                                .foregroundColor(Color.gray)
                                .padding(.leading, 10)
                        }
                        TextEditor(text: $chatController.prompt.prompt)
                            .padding(.leading, 5)
                            .frame(minHeight: 35, maxHeight: 200)
                            .foregroundColor(.primary)
                            .dynamicTypeSize(.medium ... .xxLarge)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(chatController.prompt.prompt.isEmpty ? 0.75 : 1)
                            .onChange(of: chatController.prompt.prompt) { newValue, _ in
                                chatController.disabledButton = newValue.isEmpty
                            }
                            .focused(self.$promptFieldIsFocused)
                            .disabled(chatController.disabledEditor)
                    }
                    .frame(minHeight: 36)
                    
                    Button {
                        chatController.send()
                    } label: {
                        Image(systemName: "paperplane")
                            .frame(width: 20, height: 20, alignment: .center)
                            .foregroundStyle(.blue)
                    }
                    .disabled(chatController.disabledButton)
                    
                    Button {
                        chatController.resetChat()
                    } label: {
                        Image(systemName: "trash")
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }
            .padding(6)
            .background(.ultraThickMaterial)
        }
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .background(Color(NSColor.controlBackgroundColor))
        .task {
            chatController.getTags()
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic){
                HStack {
                    Picker("Model:", selection: $chatController.prompt.model) {
                        ForEach(chatController.tags?.models ?? [], id: \.self) { model in
                            Text(model.name).tag(model.name)
                        }
                    }
                    NavigationLink {
                        ManageModelsView()
                    } label: {
                        Label("Manage Models", systemImage: "gearshape")
                    }
                }
                if chatController.errorModel.showError {
                    Button {
                        chatController.showingErrorPopover.toggle()
                    } label: {
                        Label("Error", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                    .popover(isPresented: $chatController.showingErrorPopover) {
                        VStack(alignment: .leading) {
                            Text(chatController.errorModel.errorTitle)
                                .font(.title2)
                                .textSelection(.enabled)
                            Text(chatController.errorModel.errorMessage)
                                .textSelection(.enabled)
                        }
                        .padding()
                    }
                    
                } else {
                    Text("Server:")
                    Label("Connected", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                }
                Button {
                    chatController.getTags()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
