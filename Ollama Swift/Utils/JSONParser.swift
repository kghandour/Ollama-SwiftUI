//
//  JSONParser.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

class JSONParser {
    class func JSONObjectsWithData(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> Data {
        let nonEmptyLines = String(data: data, encoding: String.Encoding.utf8)!
              .components(separatedBy: "\n").filter{ !$0.isEmpty }
        let string =   "[" + nonEmptyLines.joined(separator: ",")  + "]"
        let data = string.data(using: String.Encoding.utf8)!
        return data
    }
}
