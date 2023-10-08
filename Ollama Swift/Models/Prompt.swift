//
//  Prompt.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

struct promptModel: Encodable {
    var prompt: String
    var model: String
    var systemPrompt: String
}
