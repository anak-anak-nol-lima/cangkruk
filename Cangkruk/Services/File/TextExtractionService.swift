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
import ZIPFoundation

enum TextExtractionService {
    /// A page needs OCR when its extracted text is shorter than this — likely a scanned image, not real text.
    private static let minimumTextLength = 50

    /// Extracts plain text from the file at `url`. Returns `nil` for file types not supported yet.
    /// Runs off the main thread since OCR (Case 2 fallback) can be slow for image-heavy PDFs.
    nonisolated static func extractText(from url: URL) async -> String? {
        switch url.pathExtension.lowercased() {
        case "pdf":
            return extractTextFromPDF(at: url)
        case "docx":
            return extractTextFromDocx(at: url)
        default:
            // .doc (legacy binary Word format, pre-2007) is not ZIP-based — this approach doesn't apply to it.
            return nil
        }
    }

    nonisolated private static func extractTextFromPDF(at url: URL) -> String? {
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

    nonisolated private static func ocrText(from page: PDFPage) -> String? {
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

    nonisolated private static func extractTextFromDocx(at url: URL) -> String? {
        // .docx is a ZIP archive of XML files — the document's text lives in word/document.xml.
        let archive: Archive
        do {
            archive = try Archive(url: url, accessMode: .read)
        } catch {
            print("[TextExtractionService] docx: failed to open archive: \(error)")
            return nil
        }

        guard let entry = archive["word/document.xml"] else {
            print("[TextExtractionService] docx: entry 'word/document.xml' not found. Entries found: \(archive.map(\.path))")
            return nil
        }

        var xmlData = Data()
        do {
            _ = try archive.extract(entry, consumer: { chunk in
                xmlData.append(chunk)
            })
        } catch {
            print("[TextExtractionService] docx: failed to extract entry: \(error)")
            return nil
        }

        let parser = XMLParser(data: xmlData)
        let delegate = DocxTextParserDelegate()
        parser.delegate = delegate

        guard parser.parse() else {
            print("[TextExtractionService] docx: XML parse failed: \(String(describing: parser.parserError))")
            return nil
        }

        let text = delegate.extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            print("[TextExtractionService] docx: parsed successfully but no <w:t> text was found")
        }
        return text.isEmpty ? nil : text
    }
}

/// Collects the text inside Word's `<w:t>` (text run) elements while walking word/document.xml,
/// inserting a newline at the end of each `<w:p>` (paragraph) to preserve paragraph breaks.
nonisolated private final class DocxTextParserDelegate: NSObject, XMLParserDelegate {
    private(set) var extractedText = ""
    private var isInsideTextRun = false

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        if elementName == "w:t" {
            isInsideTextRun = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideTextRun else { return }
        extractedText += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case "w:t":
            isInsideTextRun = false
        case "w:p":
            extractedText += "\n"
        default:
            break
        }
    }
}
