//
//  TextChunker.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 19/07/26.
//

import Foundation

/// Memecah teks panjang menjadi chunk kecil & aman untuk context window on-device.
/// Setiap chunk dijamin `count <= maxLength` (hard ceiling).
enum TextChunker {
    /// Target aman untuk Apple Intelligence on-device (~800–1000).
    static let defaultMaxLength = 900

    /// Batas absolut — tidak ada chunk yang boleh melebihi ini.
    static let absoluteMaxLength = 1_000

    static func split(
        _ text: String,
        maxLength: Int = defaultMaxLength
    ) -> [String] {
        let limit = min(max(1, maxLength), absoluteMaxLength)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        guard trimmed.count > limit else { return [trimmed] }

        var chunks: [String] = []
        var remaining = Substring(trimmed)

        while !remaining.isEmpty {
            if remaining.count <= limit {
                let last = String(remaining).trimmingCharacters(in: .whitespacesAndNewlines)
                if !last.isEmpty {
                    chunks.append(contentsOf: enforceHardLimit(last, limit: limit))
                }
                break
            }

            let windowEnd = remaining.index(remaining.startIndex, offsetBy: limit)
            let window = remaining[..<windowEnd]

            // Soft breaks dulu; jika OCR rapat → hard fallback di spasi / paksa potong.
            let splitIndex = preferredSplitIndex(in: window, limit: limit)

            var piece = String(remaining[..<splitIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            // Safety net: tidak pernah loloskan chunk > limit.
            if piece.count > limit {
                let forced = enforceHardLimit(piece, limit: limit)
                chunks.append(contentsOf: forced.dropLast())
                piece = forced.last ?? ""
            }

            if !piece.isEmpty {
                chunks.append(piece)
            }

            // Maju pointer; jika split gagal maju (index == start), paksa majukan 1 char.
            if splitIndex <= remaining.startIndex {
                remaining = remaining.dropFirst()
            } else {
                remaining = remaining[splitIndex...]
                    .drop(while: { $0.isNewline || $0.isWhitespace })
            }
        }

        // Final guarantee: flatten & re-enforce.
        return chunks.flatMap { enforceHardLimit($0, limit: limit) }
    }

    /// Soft → hard: paragraf, baris, kalimat, spasi terdekat, lalu potong paksa.
    private static func preferredSplitIndex(in window: Substring, limit: Int) -> String.Index {
        if let index = lastBreak(in: window, separator: "\n\n"), index > window.startIndex {
            return index
        }
        if let index = lastBreak(in: window, separator: "\n"), index > window.startIndex {
            return index
        }
        if let index = lastSentenceBreak(in: window), index > window.startIndex {
            return index
        }
        // Hard fallback: spasi terdekat sebelum batas.
        if let index = lastBreak(in: window, separator: " "), index > window.startIndex {
            return index
        }
        // OCR tanpa spasi/tanda baca sama sekali → potong paksa di batas.
        return window.endIndex
    }

    /// Memotong paksa string agar setiap bagian ≤ `limit` (di spasi bila ada).
    private static func enforceHardLimit(_ text: String, limit: Int) -> [String] {
        guard text.count > limit else {
            return text.isEmpty ? [] : [text]
        }

        var parts: [String] = []
        var remaining = Substring(text)

        while !remaining.isEmpty {
            if remaining.count <= limit {
                let last = String(remaining).trimmingCharacters(in: .whitespacesAndNewlines)
                if !last.isEmpty { parts.append(last) }
                break
            }

            let windowEnd = remaining.index(remaining.startIndex, offsetBy: limit)
            let window = remaining[..<windowEnd]

            let splitIndex: String.Index
            if let space = lastBreak(in: window, separator: " "), space > window.startIndex {
                splitIndex = space
            } else {
                splitIndex = windowEnd
            }

            let piece = String(remaining[..<splitIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !piece.isEmpty {
                // Absolute: jika masih kebesaran (mis. satu "kata" raksasa), potong karakter.
                if piece.count > limit {
                    var start = piece.startIndex
                    while start < piece.endIndex {
                        let end = piece.index(start, offsetBy: limit, limitedBy: piece.endIndex) ?? piece.endIndex
                        parts.append(String(piece[start..<end]))
                        start = end
                    }
                } else {
                    parts.append(piece)
                }
            }

            if splitIndex <= remaining.startIndex {
                remaining = remaining.dropFirst()
            } else {
                remaining = remaining[splitIndex...]
                    .drop(while: { $0.isWhitespace || $0.isNewline })
            }
        }

        return parts
    }

    private static func lastBreak(in window: Substring, separator: String) -> String.Index? {
        guard let range = window.range(of: separator, options: .backwards) else { return nil }
        let index = range.upperBound
        guard index > window.startIndex else { return nil }
        return index
    }

    private static func lastSentenceBreak(in window: Substring) -> String.Index? {
        let terminators: Set<Character> = [".", "!", "?", "。", ";", ":"]
        for index in window.indices.reversed() {
            guard terminators.contains(window[index]) else { continue }
            let after = window.index(after: index)
            if after == window.endIndex || window[after].isWhitespace || window[after].isNewline {
                guard after > window.startIndex else { return nil }
                return after
            }
        }
        return nil
    }
}
