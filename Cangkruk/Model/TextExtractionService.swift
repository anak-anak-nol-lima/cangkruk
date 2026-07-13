//
//  TextExtractionService.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import Foundation
import PDFKit

enum TextExtractionService {
    /// Extracts plain text from the file at `url`. Returns `nil` for file types not supported yet.
    static func extractText(from url: URL) -> String? {
        switch url.pathExtension.lowercased() {
        case "pdf":
            return extractTextFromPDF(at: url)
        default:
            // TODO: Case 3 — .docx extraction (unzip + parse word/document.xml) not implemented yet
            return nil
        }
    }

    private static func extractTextFromPDF(at url: URL) -> String? {
        guard let document = PDFDocument(url: url) else { return nil }

        var pageTexts: [String] = []
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }

            // TODO: Case 2 — pages with little/no text are scanned images and need OCR (Vision), not implemented yet
            if let pageText = page.string, !pageText.isEmpty {
                pageTexts.append(pageText)
            }
        }

        let combined = pageTexts.joined(separator: "\n\n")
        return combined.isEmpty ? nil : combined
    }
}
