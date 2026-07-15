//
//  HasilScreen.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 14/07/26.
//

import SwiftUI

struct HasilScreen: View {
    let summary: String
    let feedback: String
    
    private var shareText: String {
            """
            HASIL TES LEVEL 1

            Summary:
            \(summary)

            Feedback:
            \(feedback)
            """
        }
    

    var pageToShare: some View {
        VStack(spacing: 20) {
            Text("HASIL TES LEVEL 1")
                .font(.title2).bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("Summary:").bold()
                Text(summary)
                Text("Feedback:").bold()
                Text(feedback)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.98, green: 0.95, blue: 0.89))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .frame(width: 350)
        .background(Color.white)
    }

    var body: some View {
        VStack(spacing: 20) {
            pageToShare
            ShareLink(item: shareText) {
                Label("Bagikan Halaman", systemImage: "square.and.arrow.up")
            }
        }
    }

    @MainActor
    func renderPageToImage() -> UIImage? {
        let renderer = ImageRenderer(content: pageToShare)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

struct SharePhoto: Transferable {
    let image: Image
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
}

#Preview {
    HasilScreen(
        summary: "Kamu sudah menunjukkan keramahan yang baik saat menyapa.",
        feedback: "Tadi kamu langsung bilang \"oke\" tanpa mengulang pesanan. Coba ulangi: \"Jadi, satu Latte dan satu Americano, ya?\""
    )
}
