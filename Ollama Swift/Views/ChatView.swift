//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI

struct ChatView: View {
    let fontSize: CGFloat = 15
    @EnvironmentObject var viewModel: ChatViewModel
    @FocusState private var promptFieldIsFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ChatScrollView()
                .environmentObject(viewModel)

            ChatInputView(promptFieldIsFocused: _promptFieldIsFocused)
                .environmentObject(viewModel)
        }
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .background(Color(NSColor.controlBackgroundColor))
        .task {
            viewModel.getTags()
        }
        .toolbar {
            ChatToolbar(viewModel: _viewModel)
        }
    }
}


#Preview {
    ChatView()
        .environmentObject(ChatViewModel(chatService: ChatService()))
}
