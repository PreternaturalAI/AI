//
// Copyright (c) Vatsal Manot
//

import CryptoKit
import Foundation
import Swallow

enum TokenizerResources {
    static func loadTiktokenBPE(
        url: String,
        decoder: _VocabularyFileDecoder = _VocabularyFileDecoder()
    ) async throws -> [[UInt8]: Int] {
        guard let data = try await TokenizerResources.fetch(stringUrl: url) else {
            return [:]
        }
        
        return decoder.decode(data)
    }
    
    static func dataGymToMergeableBPERanks(
        vocabularyBPEFile: String,
        encoderJsonFile: String? = nil
    ) async -> [[UInt8]: Int] {
        var rankToIntByte = (0..<exponentialPow).filter({ Character($0).isPrintable && !Character($0).isWhitespace })
        var dataGymByteToByte: [Character: Int] = toDictionary(array: rankToIntByte)
        
        var n = 0
        (0..<exponentialPow)
            .forEach({
                if !rankToIntByte.contains($0) {
                    rankToIntByte.append($0)
                    dataGymByteToByte[Character(exponentialPow + n)] = $0
                    n += 1
                }
            })
        
        let bpeMerges: [(String, String)] = await getVocab(url: vocabularyBPEFile)
        var bpeRanks: [[UInt8]: Int] = .init()
        rankToIntByte.enumerated().forEach({
            let key = Array(Character($0.element).utf16).map({ UInt8($0) })
            bpeRanks[key] = $0.offset
        })
        
        n = bpeRanks.count
        bpeMerges.forEach({
            let first = stringToArray(value: $0.0, dict: dataGymByteToByte)
            let second = stringToArray(value: $0.1, dict: dataGymByteToByte)
            let arrayInt = (first + second).map({ UInt8($0) })
            bpeRanks[arrayInt] = n
            n += 1
        })
        
        return bpeRanks
    }
}

private extension TokenizerResources {
    
    private static let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    static var exponentialPow: Int {
        Int(pow(2.0, 8))
    }
    
    static func stringToArray(value: String, dict: [Character: Int]) -> [Int] {
        value.compactMap({ dict[$0] })
    }
    
    static func toDictionary(array: [Int]) -> [Character: Int] {
        array.reduce(into: [:], { $0[Character($1)] = $1 })
    }
    
    // Fetch data
    static func fetch(stringUrl: String) async throws -> Data? {
        let urlHash = stringUrl._SHA256
        
        // Create a URL for cache file
        let cacheFileURL = cacheDirectoryURL.appendingPathComponent("\(urlHash)")
        
        // Check if the data exists in cache
        if FileManager.default.fileExists(atPath: cacheFileURL.path) {
            let data = try? Data(contentsOf: cacheFileURL)
            return data
        } else {
            guard let url = URL(string: stringUrl) else { return nil }
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Save data to cache
            do {
                try data.write(to: cacheFileURL)
            } catch {
                print("Error while caching: \(error)")
            }
            
            return data
        }
    }
    
    static func getVocab(url: String) async -> [(String, String)] {
        guard let data = try? await fetch(stringUrl: url),
              let vocab = String(data: data, encoding: .utf8)
        else {
            return []
        }
        
        return vocab
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap {
                guard !$0.starts(with: "#version") else {
                    return nil
                }
                
                let line = String($0).splitOnWhitespace()
                
                guard let first = line.first,
                      let last = line.last
                else {
                    return nil
                }
                
                return (first, last)
            }
    }
    
    static func getDecoder(url: String) async -> [String: Int] {
        guard let data = try? await fetch(stringUrl: url),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return [:] }
        return decoded
    }
}

// MARK: - Auxiliary

extension String {
    var _SHA256: String {
        let data = Data(self.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func splitOnWhitespace() -> [String] {
        split(separator: " ").map({ String($0) })
    }
}

extension Character {
    fileprivate var isPrintable: Bool {
        unicodeScalars.contains(where: { $0.isPrintable })
    }

    fileprivate init(_ i: Int) {
        self.self = Character(UnicodeScalar(i)!)
    }
}

extension Unicode.Scalar {
    fileprivate var isPrintable: Bool {
        switch properties.generalCategory {
            case .control, .format:
                return false
            default:
                return true
        }
    }
}
