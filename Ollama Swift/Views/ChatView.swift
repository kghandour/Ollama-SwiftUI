//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import MarkdownUI
import SwiftUI

struct ChatView: View {
    let fontSize: CGFloat = 15
    
    @EnvironmentObject var viewModel: ChatViewModel
    @FocusState private var promptFieldIsFocused: Bool
    @State private var showingErrorPopover: Bool = false
    
    var body: some View {
        VStack(spacing: 0)
        {
            ScrollView {
                Text("This is the start of your chat")
                    .foregroundStyle(.secondary)
                    .padding()
                ForEach(Array(self.viewModel.sentPrompt.enumerated()), id: \.offset) { idx, sent in
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
                            .init(self.viewModel.receivedResponse.indices.contains(idx) ?
                                  self.viewModel.receivedResponse[idx].trimmingCharacters(in: .whitespacesAndNewlines) :
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
            }
            .defaultScrollAnchor(.bottom)
            HStack(alignment: .bottom){
                TextField("Enter prompt...", text: self.viewModel.disabledEditor ? .constant(self.viewModel.prompt.prompt) : self.$viewModel.prompt.prompt, axis: .vertical)
                    .lineLimit(5)
                    .onChange(of: self.viewModel.prompt.prompt) {
                        if self.viewModel.prompt.prompt.count > 0 {
                            self.viewModel.disabledButton = false
                        } else {
                            self.viewModel.disabledButton = true
                        }
                    }
                    .focused(self.$promptFieldIsFocused)
                    .disabled(self.viewModel.disabledEditor)
                    .onSubmit {
                        !self.viewModel.disabledButton ? self.viewModel.send() : nil
                    }
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    self.viewModel.send()
                } label: {
                    Image(systemName: "paperplane")
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundStyle(.blue)
                }
                .disabled(self.viewModel.disabledButton)
                
                Button {
                    self.viewModel.resetChat()
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            .padding()
            .background(.ultraThickMaterial)
        }
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .background(Color(NSColor.controlBackgroundColor))
        .task {
            self.viewModel.getTags()
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic){
                HStack {
                    Picker("Model:", selection: self.$viewModel.prompt.model) {
                        ForEach(self.viewModel.tags?.models ?? [], id: \.self) { model in
                            Text(model.name).tag(model.name)
                        }
                    }
                    NavigationLink {
                        ManageModelsView()
                    } label: {
                        Label("Manage Models", systemImage: "gearshape")
                    }
                }
                if self.viewModel.errorModel.showError {
                    Button {
                        self.showingErrorPopover.toggle()
                    } label: {
                        Label("Error", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                    .popover(isPresented: self.$showingErrorPopover) {
                        VStack(alignment: .leading) {
                            Text(self.viewModel.errorModel.errorTitle)
                                .font(.title2)
                                .textSelection(.enabled)
                            Text(self.viewModel.errorModel.errorMessage)
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
                    self.viewModel.getTags()
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
        .environmentObject(ChatViewModel(chatService: ChatService()))
}
