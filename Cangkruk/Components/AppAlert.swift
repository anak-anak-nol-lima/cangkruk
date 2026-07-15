//
//  AppAlert.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 14/07/26.
//

import SwiftUI

struct AppAlert: View {
    @Binding var isPresented: Bool
    
    var message: String
    var primaryButtonTitle: String
    var secondaryButtonTitle: String = "KEMBALI"
    
    var primaryAction: () -> Void
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                    .zIndex(1)
                
                VStack(spacing: 15) {
                    Text(message)
                        .font(.shakyComicBold(size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("Secondary"))
                    
                    HStack(spacing: 16) {
                        // Secondary Button
                        Button {
                            if let secondaryAction = secondaryAction {
                                secondaryAction()
                            }
                            isPresented = false
                        } label: {
                            Text(secondaryButtonTitle)
                                .font(.shakyComicBold(size: 24))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color("lightBackground"))
                                .foregroundStyle(Color("Primary"))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color("Primary"), lineWidth: 1)
                                )
                        }
                        
                        // Primary Button
                        Button {
                            primaryAction()
                            isPresented = false
                        } label: {
                            Text(primaryButtonTitle)
                                .font(.shakyComicBold(size: 24))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color("Primary"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .padding(20)
                .background(Color("lightBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 40)
                .zIndex(2)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
    }
}

#Preview {
    AppAlert(
        isPresented: .constant(true),
        message: "APAKAH ANDA YAKIN INGIN MEMBATALKAN PERUBAHAN?",
        primaryButtonTitle: "KEMBALI",
        secondaryButtonTitle: "HAPUS",
        primaryAction: {
            print("Tombol Utama Ditekan")
        },
        secondaryAction: {
            print("Tombol Kedua Ditekan")
        }
    )
}
