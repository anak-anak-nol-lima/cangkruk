//
//  AppLevel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI

struct AppLevel: View {
    // MARK: - From props
    var level: Int
    var description: String
    var isLock: Bool
    var isManager: Bool
    var toggleLock: () -> Void
    var onClick: () -> Void
        
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Capaian \(level)")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 8)
                
                Text(description)
                    .font(.default)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            
            Spacer()
            
            if isManager {
                Image(systemName: isLock ? "lock.fill" : "lock.open.fill")
                    .frame(width: 50, height: 50)
                    .foregroundStyle(isLock ? .white : .black)
                    .background(isLock ? .black : .white)
                    .overlay {
                        Circle()
                            .stroke(.black, lineWidth: 1.5)
                    }
                    .clipShape(Circle())
                    .onTapGesture {
                        toggleLock()
                    }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 10)
        .padding(.bottom, 12)
        .onTapGesture {
            onClick()
        }
    }
}

#Preview {
    VStack {
        AppLevel(
            level: 1,
            description: "Pengetahuan akan produk",
            isLock: false,
            isManager: true
        ) {
            
        } onClick: {
            
        }
    }
    .padding()
}
