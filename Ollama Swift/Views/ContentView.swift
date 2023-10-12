//
//  ContentView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 07.10.23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationSplitView {
            MenuView(menuOptions: menuOptions)
        } detail: {
            ChatView()
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    ContentView()
}
