//
//  ChatScrollView.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import MarkdownUI
import SwiftUI

struct ChatScrollView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var body: some View {
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
    }
}
