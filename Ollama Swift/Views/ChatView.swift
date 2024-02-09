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
    
    @State private var prompt: PromptModel = .init(prompt: "", model: "", system: "")
    @State private var sentPrompt: [String] = []
    @State private var receivedResponse: [String] = []
    @State private var tags: tagsParent?
    @State private var disabledButton: Bool = true
    @State private var disabledEditor: Bool = false
    @State private var showingErrorPopover: Bool = false
    @State private var errorModel: ErrorModel = .init(showError: false, errorTitle: "", errorMessage: "")
    @FocusState private var promptFieldIsFocused: Bool
    @AppStorage("host") private var host = "http://127.0.0.1"
    @AppStorage("port") private var port = "11434"
    @AppStorage("timeoutRequest") private var timeoutRequest = "60"
    @AppStorage("timeoutResource") private var timeoutResource = "604800"
    
    var body: some View {
        VStack(spacing: 0)
        {
            ScrollView {
                Text("This is the start of your chat")
                    .foregroundStyle(.secondary)
                    .padding()
                ForEach(Array(self.sentPrompt.enumerated()), id: \.offset) { idx, sent in
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
                            .init(self.receivedResponse.indices.contains(idx) ?
                                  self.receivedResponse[idx].trimmingCharacters(in: .whitespacesAndNewlines) :
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
            HStack {
                TextField("Enter system prompt...", text: self.$prompt.system, axis: .vertical)
                    .lineLimit(3)
                    .disabled(self.disabledEditor)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            .background(.ultraThickMaterial)
            HStack(alignment: .bottom){
                TextField("Enter prompt...", text: self.disabledEditor ? .constant(self.prompt.prompt) : self.$prompt.prompt, axis: .vertical)
                    .lineLimit(5)
                    .onChange(of: self.prompt.prompt) {
                        if self.prompt.prompt.count > 0 {
                            self.disabledButton = false
                        } else {
                            self.disabledButton = true
                        }
                    }
                    .focused(self.$promptFieldIsFocused)
                    .disabled(self.disabledEditor)
                    .onSubmit {
                        !self.disabledButton ? self.send() : nil
                    }
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    self.send()
                } label: {
                    Image(systemName: "paperplane")
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundStyle(.blue)
                }
                .disabled(self.disabledButton)
                
                Button {
                    self.resetChat()
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
            self.getTags()
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic){
                HStack {
                    Picker("Model:", selection: self.$prompt.model) {
                        ForEach(self.tags?.models ?? [], id: \.self) { model in
                            Text(model.name).tag(model.name)
                        }
                    }
                    NavigationLink {
                        ManageModelsView()
                    } label: {
                        Label("Manage Models", systemImage: "gearshape")
                    }
                }
                if self.errorModel.showError {
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
                    
                } else {
                    Text("Server:")
                    Label("Connected", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                }
                Button {
                    self.getTags()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
        }
    }
    
    func getTags() {
        Task {
            do {
                self.disabledButton = false
                self.disabledEditor = false
                self.errorModel.showError = false
                self.tags = try await getLocalModels(host: "\(self.host):\(self.port)", timeoutRequest: self.timeoutRequest, timeoutResource: self.timeoutResource)
                if(self.tags != nil){
                    if(self.tags!.models.count > 0){
                        self.prompt.model = self.tags!.models[0].name
                    }else{
                        self.prompt.model = ""
                        self.errorModel = noModelsError(error: nil)
                    }
                }else{
                    self.prompt.model = ""
                    self.errorModel = noModelsError(error: nil)
                }
            } catch let NetError.invalidURL(error) {
                self.errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                self.errorModel = invalidTagsDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                self.errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                self.errorModel = unreachableError(error: error)
            } catch {
                self.errorModel = genericError(error: error)
            }
        }
    }
    
    func resetChat() {
        self.sentPrompt = []
        self.receivedResponse = []
    }
    
    func send() {
        Task {
            do {
                self.errorModel.showError = false
                self.disabledEditor = true
                
                self.sentPrompt.append(self.prompt.prompt)
                
                var chatHistory = ChatModel(model: self.prompt.model, messages: [])
                
                for i in 0 ..< self.sentPrompt.count {
                    chatHistory.messages.append(ChatMessage(role: "user", content: self.sentPrompt[i]))
                    if i < self.receivedResponse.count {
                        chatHistory.messages.append(ChatMessage(role: "assistant", content: self.receivedResponse[i]))
                    }
                }
                
                self.receivedResponse.append("")
                
                print("Sending request")
                let endpoint = "\(host):\(port)" + "/api/chat"
                
                guard let url = URL(string: endpoint) else {
                    throw NetError.invalidURL(error: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                request.httpBody = try encoder.encode(chatHistory)
                
                let data: URLSession.AsyncBytes
                let response: URLResponse
                
                do {
                    let sessionConfig = URLSessionConfiguration.default
                    sessionConfig.timeoutIntervalForRequest = Double(timeoutRequest) ?? 60
                    sessionConfig.timeoutIntervalForResource = Double(timeoutResource) ?? 604800
                    (data, response) = try await URLSession(configuration: sessionConfig).bytes(for: request)
                } catch {
                    throw NetError.unreachable(error: error)
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetError.invalidResponse(error: nil)
                }
                
                for try await line in data.lines {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let data = line.data(using: .utf8)!
                    let decoded = try decoder.decode(ResponseModel.self, from: data)
                    self.receivedResponse[self.receivedResponse.count - 1].append(decoded.message.content)
                }
                self.disabledEditor = false
                self.prompt.prompt = ""
            } catch let NetError.invalidURL(error) {
                errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                errorModel = invalidDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                errorModel = unreachableError(error: error)
            } catch {
                self.errorModel = genericError(error: error)
            }
        }
    }
}

#Preview {
    ChatView()
}
