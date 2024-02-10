//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

struct _VocabularyFileDecoder {
    func decode(
        _ data: Data
    ) -> [[UInt8]: Int] {
        guard let decoded = String(data: data, encoding: .utf8) else {
            return [:]
        }
        
        var result: [[UInt8]: Int] = .init()
        
        decoded.split(separator: "\n").forEach {
            let lineSplit = $0.split(separator: " ")
            
            guard
                let first = lineSplit.first,
                let key = try? String(from: String(first), using: .base64),
                let value = lineSplit.last
            else {
                return
            }
            
            result[key.utf16AsUInt8Array] = Int(value)
        }
        
        return result
    }
}

// MARK: - Helpers

extension String {
    fileprivate var utf16AsUInt8Array: [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(utf16.count * 2)
        
        for codeUnit in utf16 {
            let highByte = UInt8(codeUnit >> 8)
            let lowByte = UInt8(codeUnit & 0xFF)
            if highByte != 0 { bytes.append(highByte) }
            bytes.append(lowByte)
        }
        
        return bytes
    }
}
