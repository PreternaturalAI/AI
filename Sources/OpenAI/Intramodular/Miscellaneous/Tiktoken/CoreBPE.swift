//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

class CoreBPE {
    private let encoder: [[UInt8]: Int]
    private let specialTokensEncoder: [String: Int]
    private let decoder: [Int: [UInt8]]
    private let specialTokensDecoder: [Int: Data]
    private let regexTls: [NSRegularExpression]
    private let specialRegexTls: [NSRegularExpression]
    private let sortedTokenBytes: [Data]
    
    init(encoder: [[UInt8]: Int] = .init(),
         specialTokensEncoder: [String: Int] = .init(),
         decoder: [Int: [UInt8]] = .init(),
         specialTokensDecoder: [Int: Data] = .init(),
         regexTls: [NSRegularExpression] = .init(),
         specialRegexTls: [NSRegularExpression] = .init(),
         sortedTokenBytes: [Data] = .init()
    ) {
        self.encoder = encoder
        self.specialTokensEncoder = specialTokensEncoder
        self.decoder = decoder
        self.specialTokensDecoder = specialTokensDecoder
        self.regexTls = regexTls
        self.specialRegexTls = specialRegexTls
        self.sortedTokenBytes = sortedTokenBytes
    }
    
    func encodeOrdinaryNative(
        text: String
    ) -> [Int] {
        let regex = regexTls.first!
        var ret = [Int]()
        for mat in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(mat.range, in: text) {
                let piece = Array(text[range].utf8)
                if let token = encoder[piece] {
                    ret.append(token)
                    continue
                }
                let encoded = bytePairEncode([UInt8](piece), encoder)
                ret.append(contentsOf: encoded)
            }
        }
        return ret
    }
    
    func decodeNative(
        tokens: [Int]
    ) -> String {
        let data = tokens.reduce(into: Data(), {
            if let tokenBytes = decoder[$1] {
                $0.append(contentsOf: tokenBytes)
            }
        })
        return String(data: data, encoding: .utf8) ?? ""
    }
}

private extension CoreBPE {
    func increaseLastPieceTokenLen(
        tokens: [Int],
        lastPieceTokenLen: Int
    ) -> ([Int], Int) {
        func tokenIsAllSpace(_ token: Int) -> Bool {
            guard let tokenBytes = decoder[token] else {
                return false
            }
            
            return tokenBytes.reversed().allSatisfy {
                [
                    32,
                    10,
                    9
                ].contains($0)
            } // WARNING: .all(|&b| [b' ', b'\n', b'\t'].contains(&b))
        }
        
        var lastPieceTokenLen = lastPieceTokenLen
        
        if lastPieceTokenLen > 0 && tokenIsAllSpace(tokens[tokens.count - lastPieceTokenLen]) {
            while lastPieceTokenLen < tokens.count && tokenIsAllSpace(tokens[tokens.count - lastPieceTokenLen - 1]) {
                lastPieceTokenLen += 1
            }
        }
        
        assert(lastPieceTokenLen <= tokens.count)
        
        return (tokens, lastPieceTokenLen)
    }
}

// MARK: - Merges

private extension CoreBPE {
    func bytePairMerge<T>(
        _ piece: [UInt8],
        _ ranks: [[UInt8]: Int],
        completion: (Range<Int>) -> T
    ) -> [T] {
        // This is a vector of (start, rank).
        // The rank is of the byte pair starting at position start.
        // The rank of the last item in the vector is not a valid value.
        var parts = (0..<piece.count + 1).map({ ($0, Int.max) })
        
        let getRank: ([(Int, Int)], Int, Int) -> Int? = { parts, startIdx, skip in
            let calculatedIndex = startIdx + skip + 2
            if calculatedIndex < parts.count {
                let range = parts[startIdx].0..<parts[calculatedIndex].0
                let subPiece = Array(piece[range])
                return ranks[subPiece]
            } else {
                return nil
            }
        }
        
        // We look up the ranks once in the beginning and iteratively update
        // them during each merge, which reduces the number of rank lookups.
        for i in 0..<(parts.count - 2) {
            if let rank = getRank(parts, i, 0) {
                assert(rank != Int.max)
                parts[i].1 = rank
            }
        }
        
        // If you have n parts and m merges, this does O(mn) work.
        // We could do something with a heap and do O(m log n) work.
        // It is important to consider that n is often small (<100), and as such
        // the cache-locality benefits outweigh the algorithmic complexity downsides
        // of the `parts` vector data structure above.
        
        // Note that we hash bytes, not token pairs. As long as we train BPE the way we
        // currently do, this is equivalent. An easy way to break this would be to decouple
        // merge priority from token index or to prevent specific token merges.
        while parts.count > 1 {
            // usize::MAX is a sentinel rank value allowing us to
            // take the min more quickly
            var minRank = (Int.max, 0)
            for (i, ( _, rank)) in parts.enumerated() {
                if rank < minRank.0 {
                    minRank = (rank, i)
                }
            }
            
            if minRank.0 != Int.max {
                let i = minRank.1
                
                // NOTE: We are about to remove parts[i + 1]. We do not do it
                // yet because there are cache-locality benefits to updating
                // parts[i] and parts[i-1] before removing, which could thrash
                // the cache. Thus, we update the rank calculation by skipping over
                // parts[i + 1], by invoking `get_rank!` with `skip = 1`.
                parts[i].1 = getRank(parts, i, 1) ?? Int.max
                if i > 0 {
                    parts[i - 1].1 = getRank(parts, i - 1, 1) ?? Int.max
                }
                parts.remove(at: i + 1)
            } else {
                break
            }
        }
        
        // TODO: Use ranks
        return parts.prevCurrent({ completion($0.0..<$1.0) })
    }
    
    func bytePairEncode(_ piece: [UInt8], _ ranks: [[UInt8]: Int]) -> [Int] {
        if piece.count == 1 {
            return [ranks[piece]!]
        }
        return bytePairMerge(piece, ranks, completion: { p in
            let chunk = Array(piece[p])
            return ranks[chunk] ?? 0
        })
    }
    
    //    func bytePairSplit(_ piece: [UInt8], _ ranks: [[UInt8]: Int]) -> [[UInt8]] {
    //        if piece.count == 1 {
    //            return [piece]
    //        }
    //        return bytePairMerge(piece, ranks, completion: { Array(piece[$0]) })
    //    }
}

// MARK: - Auxiliary

extension Array {
    fileprivate func prevCurrent<T>(
        _ body: (Element, Element) throws -> T
    ) rethrows -> [T] {
        enumerated().compactMap({ index, element in
            guard index > 0 else { return nil }
            let prev = self[index-1]
            return try? body(prev, element)
        })
    }
}
