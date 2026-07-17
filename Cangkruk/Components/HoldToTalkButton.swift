//
//  HoldToTalkButton.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 17/07/26.
//
import SwiftUI
struct HoldToTalkButton: View {
    var onPressedChange: (Bool) -> Void
    
    @State private var isPressed = false
    
    var body: some View{
        Circle()
            .fill(Color("Primary"))
            .frame(width: 110, height: 110)
            .scaleEffect(isPressed ? 1.15: 1.0)
            .animation(.spring(duration: 0.2), value: isPressed)
            .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isPressed else { return }
                isPressed = true
                onPressedChange(true)
            }
            .onEnded{ _ in
                isPressed = false
                onPressedChange(false)
            }
        )
    }
}
