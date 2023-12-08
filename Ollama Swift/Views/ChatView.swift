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
    
    @State private var prompt: promptModel = .init(prompt: "", model: "", system: "")
    @State private var sentPrompt: [String] = []
    @State private var receivedResponse: [String] = []
    @State private var tags: tagsParent?
    @State private var disabledButton: Bool = true
    @State private var disabledEditor: Bool = false
    @State private var errorModel: ErrorModel = .init(showError: false, errorTitle: "", errorMessage: "")
    @FocusState private var promptFieldIsFocused: Bool
    @AppStorage("host") private var host = "http://127.0.0.1"
    @AppStorage("port") private var port = "11434"
    
    var body: some View {
        VStack {
            ScrollView {
                Text("This is the start of your chat")
                    .foregroundStyle(.secondary)
                    .padding()
                ForEach(Array(self.sentPrompt.enumerated()), id: \.offset) { idx, sent in
                    ChatBubble(direction: .right) {
                        Markdown {
                            .init(sent.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 8)
                        .textSelection(.enabled)
                        .foregroundStyle( Color(nsColor:.controlTextColor))
                        .background(Color(nsColor:.controlColor))
                    }
                    ChatBubble(direction: .left) {
                        Markdown {
                            .init(self.receivedResponse.indices.contains(idx) ?
                                self.receivedResponse[idx].trimmingCharacters(in: .whitespacesAndNewlines) :
                                "...")
                        }
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 8)
                        .textSelection(.enabled)
                        .foregroundStyle( Color(nsColor: .controlTextColor))
                        .background(Color(nsColor: .controlAccentColor))
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
            Spacer()
            HStack {
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
                }
                .disabled(self.disabledButton)
                
                Button {
                    self.resetChat()
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
        }
        .padding([.leading, .trailing, .bottom])
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .task {
            self.getTags()
        }
        .toolbar {
            HStack {
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
                Divider()
                HStack {
                    if self.errorModel.showError {
                        VStack(alignment: .leading) {
                            Text(self.errorModel.errorTitle)
                                .font(.title2)
                                .textSelection(.enabled)
                            Text(self.errorModel.errorMessage)
                                .textSelection(.enabled)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .background(.red)
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                    } else {
                        HStack {
                            Text("Server Status: ")
                            Text("Online")
                                .foregroundStyle(.green)
                        }
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
    }
    
    func getTags() {
        Task {
            do {
                self.disabledButton = false
                self.disabledEditor = false
                self.errorModel.showError = false
                self.tags = try await getLocalModels(host: "\(self.host):\(self.port)")
                self.prompt.model = self.tags?.models[0].name ?? ""
            } catch let NetError.invalidURL(error) {
                errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                errorModel = invalidTagsDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                errorModel = unreachableError(error: error)
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
                request.httpBody = try encoder.encode(self.prompt)
                
                let data: URLSession.AsyncBytes
                let response: URLResponse
                                
                do {
                    (data, response) = try await URLSession.shared.bytes(for: request)
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
                    let decoded = try decoder.decode(responseModel.self, from: data)
                    self.receivedResponse[self.receivedResponse.count - 1].append(decoded.response ?? "")
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
