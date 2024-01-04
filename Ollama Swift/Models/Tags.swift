//
//  Tags.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import Foundation

struct TagsParent: Decodable, Hashable {
    let models: [TagsModel]
}

struct TagsModel: Decodable, Hashable {
    let name: String
    let modifiedAt: String?
    let size: Double
    let digest: String
}
