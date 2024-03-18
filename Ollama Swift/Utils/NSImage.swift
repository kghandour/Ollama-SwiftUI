//
//  NSImage.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 18.03.24.
//

import Foundation
import PhotosUI

extension NSImage {

    func base64String() -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let data = bits.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey.compressionFactor:1.0])
        else {
            return nil
        }

        return "\(data.base64EncodedString())"
    }
}
