//
//  HoldToTalkButton.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 17/07/26.
//
import SwiftUI

struct HoldToTalkButton: View {
    var isRecording: Bool
    var onTap: () -> Void

    var body: some View {
        Circle()
            .fill(Color("Primary"))
            .frame(width: 110, height: 110)
            .overlay {
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            .scaleEffect(isRecording ? 1.15 : 1.0)
            .animation(.spring(duration: 0.2), value: isRecording)
            .onTapGesture {
                onTap()
            }
    }
}
