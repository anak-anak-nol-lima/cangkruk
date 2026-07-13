//
//  TextExtractionService.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import Foundation
import PDFKit
import Vision
import UIKit

enum TextExtractionService {
    /// A page needs OCR when its extracted text is shorter than this — likely a scanned image, not real text.
    private static let minimumTextLength = 50

    /// Extracts plain text from the file at `url`. Returns `nil` for file types not supported yet.
    /// Runs off the main thread since OCR (Case 2 fallback) can be slow for image-heavy PDFs.
    nonisolated static func extractText(from url: URL) async -> String? {
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

            let pageText = page.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if pageText.count >= minimumTextLength {
                // Case 1 — real text layer already present on this page.
                pageTexts.append(pageText)
            } else if let ocrText = ocrText(from: page) {
                // Case 2 — page has little/no text layer, likely a scanned image.
                pageTexts.append(ocrText)
            }
        }

        let combined = pageTexts.joined(separator: "\n\n")
        return combined.isEmpty ? nil : combined
    }

    private static func ocrText(from page: PDFPage) -> String? {
        let bounds = page.bounds(for: .mediaBox)
        guard bounds.width > 0, bounds.height > 0 else { return nil }

        let scale: CGFloat = 2 // render at 2x for sharper OCR input
        let renderSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)

        let renderer = UIGraphicsImageRenderer(size: renderSize)
        let image = renderer.image { context in
            UIColor.white.set()
            context.fill(CGRect(origin: .zero, size: renderSize))

            context.cgContext.translateBy(x: 0, y: renderSize.height)
            context.cgContext.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: context.cgContext)
        }

        guard let cgImage = image.cgImage else { return nil }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        // Note: verify Vision's on-device language support covers Indonesian on the target iOS version —
        // recognition quality for id-ID content should be checked on a real device.

        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
        } catch {
            return nil
        }

        let recognizedText = (request.results ?? [])
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")

        return recognizedText.isEmpty ? nil : recognizedText
    }
}
