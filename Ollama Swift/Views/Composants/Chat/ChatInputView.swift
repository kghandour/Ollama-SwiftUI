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
            
            SendButton(disabledButton: $viewModel.disabledButton, action: viewModel.send)
            ResetButton(action: viewModel.resetChat)
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
