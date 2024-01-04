//
//  ChatInputView.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI

struct ChatInputView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @FocusState var promptFieldIsFocused: Bool

    var body: some View {
        HStack(alignment: .bottom) {
            ZStack(alignment: .topLeading) {
                if viewModel.prompt.prompt.isEmpty {
                    Text("Enter prompt...")
                        .foregroundColor(Color.gray)
                        .padding(.leading, 10)
                        .padding(.top, 8)
                }
                
                TextEditor(text: self.$viewModel.prompt.prompt)
                    .padding(.leading, 5)
                    .padding(.top, 8)
                    .frame(minHeight: 45, maxHeight: 200)
                    .foregroundColor(.primary)
                    .dynamicTypeSize(.medium ... .xxLarge)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(viewModel.prompt.prompt.isEmpty ? 0.5 : 1)
                    .onChange(of: viewModel.prompt.prompt) { newValue, _ in
                        viewModel.disabledButton = newValue.isEmpty
                    }
                    .focused(self.$promptFieldIsFocused)
                    .disabled(viewModel.disabledEditor)
            }
            .frame(minHeight: 36)

            SendButton(disabledButton: $viewModel.disabledButton, action: {
                Task { @MainActor in
                    viewModel.send()
                }
            })
            .padding(.bottom, 8)

            ResetButton(action: {
                Task { @MainActor in
                    viewModel.resetChat()
                }
            })
            .padding(.bottom, 8)
        }
        .padding()
        .background(.ultraThickMaterial)
    }
}

struct SendButton: View {
    @Binding var disabledButton: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane")
                .frame(width: 20, height: 20, alignment: .center)
                .foregroundStyle(.blue)
        }
        .disabled(disabledButton)
    }
}

struct ResetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "trash")
                .frame(width: 20, height: 20, alignment: .center)
        }
    }
}
