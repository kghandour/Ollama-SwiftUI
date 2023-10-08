//
//  Tags.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

struct tagsParent: Decodable, Hashable {
    let models: [tagsModel]
}

struct tagsModel: Decodable, Hashable {
    let name: String
    let modifiedAt: String
    let size: Int
    let digest: String
}
