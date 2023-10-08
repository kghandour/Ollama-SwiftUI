//
//  NetworkErrors.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

enum NetError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
