//
//  ContentView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 07.10.23.
//

import SwiftUI

struct Option: Hashable {
    let title: String
    let imageName: String
}

struct ContentView: View {
    let options: [Option] = [
        .init(title: "Home", imageName: "house"),
        .init(title: "Settings", imageName: "gear")
    ]
    
    var body: some View {
        NavigationSplitView {
            ListView(options: options)
        } detail: {
            MainView()
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct ListView: View {
    let options: [Option]
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(options, id: \.self) { option in
                HStack {
                    Image(systemName: option.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    
                    Text(option.title)
                }
                .padding()
            }
        }
        
        Spacer()
    }
}

struct MainView: View {
    @State private var prompt: promptModel = promptModel(prompt: "hello", model: "mistral", systemPrompt: "")
    @State private var responses: [resultModel]?
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
                self.responses = try? await sendPrompt()
                for res in self.responses! {
                    self.backFromResponse.append(res.response ?? "")
                }
            }
        }
    }
    
    func sendPrompt() async throws -> [resultModel]{
        print("Sending request")
        let endpoint = "http://192.168.0.107:11434/api/generate"
        
        guard let url = URL(string: endpoint) else {
            throw NetError.invalidURL
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(prompt)
                
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Invalid response")
            throw NetError.invalidResponse
        }
        do {
            let json = try JSONParser.JSONObjectsWithData(data: data)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode([resultModel].self, from: json)
            return decoded
        } catch {
            print(error)
            throw NetError.invalidData
        }
    }
}

struct promptModel: Encodable {
    var prompt: String
    var model: String
    var systemPrompt: String
}

struct responseModel: Decodable, Hashable {
    var results: [resultModel]
}

struct resultModel: Decodable, Hashable {
    let model: String
    let createdAt: String
    let response: String?
    let done: Bool
    let context: [Int]?
    let total_duration: Int?
    let load_duration: Int?
    let prompt_eval_count: Int?
    let eval_count: Int?
    let eval_duration: Int?
}

enum NetError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

class JSONParser {
    class func JSONObjectsWithData(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> Data {
        let nonEmptyLines = String(data: data, encoding: String.Encoding.utf8)!
              .components(separatedBy: "\n").filter{ !$0.isEmpty }
        let string =   "[" + nonEmptyLines.joined(separator: ",")  + "]"
        let data = string.data(using: String.Encoding.utf8)!
        return data
    }
}

#Preview {
    ContentView()
}
