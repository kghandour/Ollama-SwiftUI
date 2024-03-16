//
//  ContentView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var ollamaController = OllamaController()
    var body: some View {
        NavigationStack{
            ChatView()
        }
    }
}

#Preview {
    ContentView()
}
