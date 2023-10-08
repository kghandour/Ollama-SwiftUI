//
//  Response.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

struct responseModel: Decodable, Hashable {
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
