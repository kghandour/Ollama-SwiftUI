//
//  ChatBubble.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 09.10.23.
//  Used from: https://gist.github.com/prafullakumar/aa7af213d9e7530ee82aa6e8c92505b4

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
                Spacer()
            }
            content()
                .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
            if direction == .left {
                Spacer()
            }
        }
        .padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 5)
    }
}

struct ChatBubbleShape {
    enum Direction {
        case left
        case right
    }
}
