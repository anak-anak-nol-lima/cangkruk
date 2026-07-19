//
//  ChatBubbleView.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 19/07/26.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.role == .customer { avatar("Customer") }
            if message.role == .barista { Spacer(minLength: 48) }

            Text(message.text)
                .font(.body)
                .foregroundStyle(.black.opacity(0.8))
                .padding(14)
                .background(Color("lightBackground"))
                .clipShape(bubbleShape)

            if message.role == .customer { Spacer(minLength: 48) }
            if message.role == .barista { avatar("Baristapng") }
        }
    }

   
    private var bubbleShape: UnevenRoundedRectangle {
        message.role == .customer
            ? UnevenRoundedRectangle(topLeadingRadius: 4,  bottomLeadingRadius: 16,
                                     bottomTrailingRadius: 16, topTrailingRadius: 16)
            : UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16,
                                     bottomTrailingRadius: 4,  topTrailingRadius: 16)
    }

    private func avatar(_ name: String) -> some View {
        Image(name)
            .resizable().scaledToFill()
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    VStack(spacing: 12) {
        ChatBubbleView(message: ChatMessage(role: .customer, text: "Halo, ada rekomendasi kopi yang nggak terlalu pahit?"))
        ChatBubbleView(message: ChatMessage(role: .barista, text: "Ada kak! Coba Latte, manisnya pas."))
        ChatBubbleView(message: ChatMessage(role: .customer, text: "..."))
    }
    .padding()
    .background(Color("Background"))
}
