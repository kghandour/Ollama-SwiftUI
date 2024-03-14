//
//  ChatBubble.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 09.10.23.

import SwiftUI

struct ChatBubble<Content>: View where Content: View {
    let direction: ChatBubbleShape.Direction
    let content: () -> Content
    init(direction: ChatBubbleShape.Direction, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.direction = direction
    }

    var body: some View {
        HStack {
            if direction == .right {
                Spacer(minLength: 32)
            }
            content()
                .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
            if direction == .left {
                Spacer(minLength: 32)
            }
        }
        .padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 5)
    }
}

enum ChatBubbleShape {
    enum Direction {
        case left
        case right
    }
}
