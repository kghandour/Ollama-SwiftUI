//
//  NetworkErrors.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

enum NetError: Error {
    case invalidURL(error: Error?)
    case invalidResponse(error: Error?)
    case invalidData(error: Error?)
    case unreachable(error: Error?)
    case general(error: Error?)
    case serverError(statusCode: Int)
}
